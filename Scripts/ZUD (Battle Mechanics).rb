#===============================================================================
# New battler properties.
#===============================================================================
class PokeBattle_Battler
    #-----------------------------------------------------------------------------
    # Initializes new battler effects.
    #-----------------------------------------------------------------------------
    alias _ZUD_pbInitEffects pbInitEffects  
    def pbInitEffects(batonPass,fakeBattler=false)
      _ZUD_pbInitEffects(batonPass,fakeBattler=false)
      @lastMoveUsedIsZMove                  = false
      @effects[PBEffects::BaseMoves]        = []
      @effects[PBEffects::CriticalBoost]    = 0
      @effects[PBEffects::MoveMimicked]     = false
      @effects[PBEffects::EncoreRestore]    = nil
      @effects[PBEffects::PowerMovesButton] = false
      @effects[PBEffects::TransformPokemon] = nil
      @effects[PBEffects::UsedZMoveIndex]   = -1
    end
      
    #-----------------------------------------------------------------------------
    # Checks if the battler is in one of these modes.
    #-----------------------------------------------------------------------------
    def ultra?;       return @pokemon && @pokemon.ultra?;       end
      
    #-----------------------------------------------------------------------------
    # Checks if the battler is capable of using any of the following mechanics.
    #-----------------------------------------------------------------------------
    def pbCompatibleZMove?(move=nil)
      transform = @effects[PBEffects::Transform]
      newpoke   = @effects[PBEffects::TransformPokemon] 
      pokemon   = transform ? newpoke : @pokemon
      return false if transform && pokemon.ultra? && hasActiveItem?(:ULTRANECROZIUMZ)
      return pokemon.compat_zmove?(move)
    end
    
    def hasZMove?
      return false if shadowPokemon?
      return false if primal? || hasPrimal?
      return pbCompatibleZMove?(@moves)
    end
    
    def hasUltra?
      return false if @effects[PBEffects::Transform]
      return false if shadowPokemon?
      return false if mega?   || hasMega?
      return false if primal? || hasPrimal?
      return false if ultra?
      return @pokemon && pokemon.hasUltra?
    end
  end
  
  #-------------------------------------------------------------------------------
  # Ensures Ultra Necrozma reverts from Ultra Burst after battle.
  #-------------------------------------------------------------------------------
  alias _ZUD_pbAfterBattle pbAfterBattle
  def pbAfterBattle(*args)
    $Trainer.party.each do |pkmn|
      pkmn.makeUnUltra
    end
    if $PokemonGlobal.partner
      $Trainer.heal_party
      $PokemonGlobal.partner[3].each do |pkmn|
        pkmn.heal
        pkmn.makeUnmega
        pkmn.makeUnprimal
        pkmn.makeUnUltra
      end
    end
    _ZUD_pbAfterBattle(*args)
  end
  
  #===============================================================================
  # Selecting and converting moves when using Z-Moves.
  #===============================================================================
  class PokeBattle_Battler
    #-----------------------------------------------------------------------------
    # Converts base moves into Z-Moves.
    #-----------------------------------------------------------------------------
    def pbDisplayPowerMoves(mode=0)
      # Set "mode" to 1 to convert to Z-Moves.
      newpoke  = @effects[PBEffects::TransformPokemon]
      pokemon  = @effects[PBEffects::Transform] ? newpoke : self.pokemon
      for i in @moves; @effects[PBEffects::BaseMoves].push(i); end
      for i in 0...@moves.length
        next if !@moves[i]
        # Z-Moves
        if mode==1
          next if !pokemon.compat_zmove?(@moves[i])
          @moves[i]          = PokeBattle_ZMove.from_base_move(@battle, self, @moves[i], self.item)
          @moves[i].pp       = 1
          @moves[i].total_pp = 1
        end
      end
    end
    
    #-----------------------------------------------------------------------------
    # Reverts Z-Moves into base moves.
    #-----------------------------------------------------------------------------
    def pbDisplayBaseMoves(mode=0)
      # Set "mode" to 1 to reduce PP of base move of converted Z-Move.
      # "Mode" can be omitted if there is no need to reduce PP.
      oldmoves    = []
      basemoves   = @pokemon.moves
      storedmoves = @effects[PBEffects::BaseMoves]
      # Determines base move set to revert to (considers Mimic/Transform).
      if @effects[PBEffects::MoveMimicked]
        for i in 0...@moves.length
          next if !@moves[i]
          if basemoves[i]==storedmoves[i]
            oldmoves.push(basemoves[i])
          else
            oldmoves.push(storedmoves[i])
          end
        end
      elsif @effects[PBEffects::Transform]
        oldmoves = storedmoves
      else
        oldmoves = basemoves
      end
      for i in 0...@moves.length
        next if !@moves[i]
        if oldmoves[i].is_a?(PokeBattle_Move)
          @moves[i] = oldmoves[i]
        else
          @moves[i] = PokeBattle_Move.from_pokemon_move(@battle,oldmoves[i])
        end
        @moves[i].pp -= 1 if i==@effects[PBEffects::UsedZMoveIndex] && mode==1
        @moves[i].pp = 0 if @moves[i].pp<0
        if !@effects[PBEffects::Transform]
          @pokemon.moves[i].pp -= 1 if i==@effects[PBEffects::UsedZMoveIndex] && mode==1
          @pokemon.moves[i].pp = 0 if @pokemon.moves[i].pp<0
        end
      end
      @effects[PBEffects::BaseMoves] = []
    end
    
    #-----------------------------------------------------------------------------
    # Effects that may change a Z-Move into one of a different type.
    #-----------------------------------------------------------------------------
    def pbChangePowerMove(choice)
      thismove = choice[2]
      if thismove.powerMove?
        basemove = @effects[PBEffects::BaseMoves][choice[1]]
        newtype  = :ELECTRIC if @effects[PBEffects::Electrify]
        newtype  = :ELECTRIC if @battle.field.effects[PBEffects::IonDeluge] && thismove.type==:NORMAL
  =begin
        if thismove.type==:NORMAL && thismove.damagingMove?
          #-------------------------------------------------------------------------
          # Weather is in play and base move is Weather Ball.
          #-------------------------------------------------------------------------
          if basemove.id==:WEATHERBALL
            case @battle.pbWeather
            when :Sun, :HarshSun;   newtype = :FIRE
            when :Rain, :HeavyRain; newtype = :WATER
            when :Sandstorm;        newtype = :ROCK
            when :Hail;             newtype = :ICE
            end
          #-------------------------------------------------------------------------
          # Terrain is in play and base move is Terrain Pulse.
          #-------------------------------------------------------------------------
          elsif basemove.id==:TERRAINPULSE
            case @battle.field.terrain
            when :Electric;         newtype = :ELECTRIC
            when :Grassy;           newtype = :GRASS
            when :Misty;            newtype = :FAIRY
            when :Psychic;          newtype = :PSYCHIC
            end
          #-------------------------------------------------------------------------
          # Base move is Revelation Dance.
          #-------------------------------------------------------------------------
          elsif basemove.id==:REVELATIONDANCE
            userTypes = pbTypes(true)
            newtype   = userTypes[0]
          #-------------------------------------------------------------------------
          # Base move is Techno Blast and a drive is held by Genesect.
          #-------------------------------------------------------------------------
          elsif basemove.id==:TECHNOBLAST && isSpecies?(:GENESECT)
            itemtype  = true
            itemTypes = {
               :SHOCKDRIVE => :ELECTRIC,
               :BURNDRIVE  => :FIRE,
               :CHILLDRIVE => :ICE,
               :DOUSEDRIVE => :WATER
            }
          #-------------------------------------------------------------------------
          # Base move is Judgment and user has Multitype and held plate.
          #-------------------------------------------------------------------------
          elsif basemove.id==:JUDGMENT && hasActiveAbility?(:MULTITYPE)
            itemtype  = true
            itemTypes = {
               :FISTPLATE   => :FIGHTING,
               :SKYPLATE    => :FLYING,
               :TOXICPLATE  => :POISON,
               :EARTHPLATE  => :GROUND,
               :STONEPLATE  => :ROCK,
               :INSECTPLATE => :BUG,
               :SPOOKYPLATE => :GHOST,
               :IRONPLATE   => :STEEL,
               :FLAMEPLATE  => :FIRE,
               :SPLASHPLATE => :WATER,
               :MEADOWPLATE => :GRASS,
               :ZAPPLATE    => :ELECTRIC,
               :MINDPLATE   => :PSYCHIC,
               :ICICLEPLATE => :ICE,
               :DRACOPLATE  => :DRAGON,
               :DREADPLATE  => :DARK,
               :PIXIEPLATE  => :FAIRY
            }
          #-------------------------------------------------------------------------
          # Base move is Multi-Attack and user has RKS System and held memory.
          #-------------------------------------------------------------------------
          elsif basemove.id==:MULTIATTACK && hasActiveAbility?(:RKSSYSTEM)
            itemtype  = true
            itemTypes = {
               :FIGHTINGMEMORY => :FIGHTING,
               :FLYINGMEMORY   => :FLYING,
               :POISONMEMORY   => :POISON,
               :GROUNDMEMORY   => :GROUND,
               :ROCKMEMORY     => :ROCK,
               :BUGMEMORY      => :BUG,
               :GHOSTMEMORY    => :GHOST,
               :STEELMEMORY    => :STEEL,
               :FIREMEMORY     => :FIRE,
               :WATERMEMORY    => :WATER,
               :GRASSMEMORY    => :GRASS,
               :ELECTRICMEMORY => :ELECTRIC,
               :PSYCHICMEMORY  => :PSYCHIC,
               :ICEMEMORY      => :ICE,
               :DRAGONMEMORY   => :DRAGON,
               :DARKMEMORY     => :DARK,
               :FAIRYMEMORY    => :FAIRY
            }
          end
          if itemActive? && itemtype
            itemTypes.each do |item, itemType|
              next if !hasActiveItem?(item)
              newtype = itemType
              break
            end
          end
        end
  =end
        if newtype && GameData::Type.exists?(newtype)
          #-------------------------------------------------------------------------
          # Z-Moves - Converts to a new Z-Move of a given type.
          #-------------------------------------------------------------------------
          if thismove.zMove?
            zMove        = @pokemon.get_zmove(newtype)
            newMove      = Pokemon::Move.new(zMove)
            moveFunction = newMove.function_code || "Z000"
            className    = sprintf("PokeBattle_Move_%s",moveFunction)
            if Object.const_defined?(className)
              return Object.const_get(className).new(battle, basemove, newMove)
            end
            return PokeBattle_ZMove.new(battle, basemove, newMove)
          end
        end
      end
      return thismove
    end
    
    #-----------------------------------------------------------------------------
    # Handles the actual use of Z-Moves, and converts to base moves when done.
    #-----------------------------------------------------------------------------\
  =begin
    def pbProcessTurn(choice,tryFlee=true)
      return false if fainted?
      if tryFlee && @battle.wildBattle? && opposes? &&
         @battle.rules["alwaysflee"] && @battle.pbCanRun?(@index)
        pbBeginTurn(choice)
        pbSEPlay("Battle flee")
        @battle.pbDisplay(_INTL("{1} fled from battle!",pbThis))
        @battle.decision = 3
        pbEndTurn(choice)
        return true
      end
      if choice[0]==:Shift
        idxOther = -1
        case @battle.pbSideSize(@index)
        when 2
          idxOther = (@index+2)%4
        when 3
          if @index!=2 && @index!=3
            idxOther = ((@index%2)==0) ? 2 : 3
          end
        end
        if idxOther>=0
          @battle.pbSwapBattlers(@index,idxOther)
          case @battle.pbSideSize(@index)
          when 2
            @battle.pbDisplay(_INTL("{1} moved across!",pbThis))
          when 3
            @battle.pbDisplay(_INTL("{1} moved to the center!",pbThis))
          end
        end
        pbBeginTurn(choice)
        pbCancelMoves
        @lastRoundMoved = @battle.turnCount
        return true
      end
      if choice[0]!=:UseMove
        pbBeginTurn(choice)
        pbEndTurn(choice)
        return false
      end
      if @effects[PBEffects::Pursuit]
        @effects[PBEffects::Pursuit] = false
        pbCancelMoves
        pbEndTurn(choice)
        @battle.pbJudge
        return false
      end
      # Z-Moves
      if choice[2].zmove_sel
        choice[2].zmove_sel = false
        @battle.pbUseZMove(self.index,choice[2],self.item)
      else
        PBDebug.log("[Move usage] #{pbThis} started using #{choice[2].name}")
        PBDebug.logonerr{pbUseMove(choice,choice[2]==@battle.struggle)}
      end
      @battle.pbJudge
      @battle.pbCalculatePriority if Settings::RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES
      @effects[PBEffects::AlwaysMiss] = -1
      return true
    end
  
    def pbUseMoveSimple(moveID,target=-1,idxMove=-1,specialUsage=true)
      choice = []
      choice[0] = :UseMove
      choice[1] = idxMove
      if idxMove>=0
        choice[2] = @moves[idxMove]
      else
        choice[2] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(moveID))
        choice[2].pp = -1
      end
      choice[3] = target
      PBDebug.log("[Move usage] #{pbThis} started using the called/simple move #{choice[2].name}")
      # Z-Moves
      side  = (@battle.opposes?(self.index)) ? 1 : 0
      owner = @battle.pbGetOwnerIndexFromBattlerIndex(self.index)
      if @battle.zMove[side][owner]==self.index
        crystal = GameData::PowerMove.item_from(choice[2].type)
        z_move  = PokeBattle_ZMove.from_base_move(@battle,self,choice[2],crystal)
        z_move.pbUse(self,choice,specialUsage)
      else
        pbUseMove(choice,specialUsage)
      end
    end
  =end
    
    alias _ZUD_pbUseMove pbUseMove
    def pbUseMove(choice,specialUsage=false)
      @lastMoveUsedIsZMove = false
      @effects[PBEffects::UsedZMoveIndex] = choice[1] if choice[2].zMove?
      choice[2] = pbChangePowerMove(choice)
      _ZUD_pbUseMove(choice,specialUsage)
    end
  end
  
  #===============================================================================
  # Checks for the success or failure of certain effects.
  #===============================================================================
  class PokeBattle_Battler
    attr_accessor :lastMoveUsedIsZMove
    
    #=============================================================================
    # Z-Move selection
    #=============================================================================
    # Bypasses effects that would normally lock the user out of move selection.
    #-----------------------------------------------------------------------------
    alias _ZUD_pbCanChooseMove? pbCanChooseMove?
    def pbCanChooseMove?(move,commandPhase,showMessages=true,specialUsage=false)
      if move.powerMove?
        # Gravity still affects Power Moves.
        if @battle.field.effects[PBEffects::Gravity]>0 && move.unusableInGravity?
          if showMessages
            msg = _INTL("{1} can't use {2} because of gravity!",pbThis,move.name)
            (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
          end
          return false
        end
        return true
      else
        return _ZUD_pbCanChooseMove?(move,commandPhase,showMessages,specialUsage)
      end
    end
    
    #=============================================================================
    # Z-Move completion check
    #=============================================================================
    # Completes the Z-Move process at the end of the turn if one was used.
    #-----------------------------------------------------------------------------
    alias _ZUD_pbTryUseMove pbTryUseMove 
    def pbTryUseMove(*args)
      ret = _ZUD_pbTryUseMove(*args)
      @lastMoveUsedIsZMove = ret if args[1].zMove?
      return ret 
    end
    
    alias _ZUD_pbEndTurn pbEndTurn
    def pbEndTurn(_choice)
      if _choice[0] == :UseMove && _choice[2].zMove?
        if @lastMoveUsedIsZMove
          side  = self.idxOwnSide
          owner = @battle.pbGetOwnerIndexFromBattlerIndex(self.index)
          @battle.zMove[side][owner] = -2
        else 
          @battle.pbUnregisterZMove(self.index)
        end
        pbDisplayBaseMoves(1)
        @effects[PBEffects::PowerMovesButton] = false
      end
      _ZUD_pbEndTurn(_choice)
    end
    
    #=============================================================================
    # Encore
    #=============================================================================
    # Index of encored move is reset during the turn a Z-Move is used.
    #-----------------------------------------------------------------------------
    alias _ZUD_pbEncoredMoveIndex pbEncoredMoveIndex
    def pbEncoredMoveIndex
      if @battle.choices[self.index][0]==:UseMove && 
         @battle.choices[self.index][2].zMove?
        turns = @effects[PBEffects::Encore]
        move  = @effects[PBEffects::EncoreMove]
        @effects[PBEffects::EncoreRestore] = [turns,move]
        return -1
      end
      _ZUD_pbEncoredMoveIndex
    end
    
    #=============================================================================
    # Imprison
    #=============================================================================
    # Prevents Z-Moves from becoming unselectable due to Imprison.
    # Must be added to def pbCanChooseMove?
    #-----------------------------------------------------------------------------
    def _ZUD_Imprison(move,commandPhase)
      @battle.eachOtherSideBattler(@index) do |b|
        next if move.powerMove?
        basemove = false
        b.eachMoveWithIndex do |m,i|
          break if b.effects[PBEffects::BaseMoves].empty?
          basemove = true if b.effects[PBEffects::BaseMoves][i].id==move.id
        end
        hasmove = b.pbHasMove?(move.id)
        next if !b.effects[PBEffects::Imprison] || !hasmove
        if showMessages
          msg = _INTL("{1} can't use its sealed {2}!",pbThis,move.name)
          (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
        end
        return false
      end
    end
     
    #=============================================================================
    # Grudge, Destiny Bond
    #=============================================================================
    # Grudge: Lowers PP of base move if Max Move was used. Fails on Z-Moves.
    # Must be added to def pbEffectsOnMakingHit.
    #=============================================================================
    def _ZUD_EffectsOnKO(move,user,target)
      # Grudge
      if target.effects[PBEffects::Grudge] && target.fainted? && !move.zMove?
        move.pp  = 0
        basemove = nil
        user.eachMoveWithIndex do |m,i|
          next if m!=move && m.pp>0
        end
        movename = (basemove) ? basemove.name : move.name  
        @battle.pbDisplay(_INTL("{1}'s {2} lost all of its PP due to the grudge!",
          user.pbThis,movename))
      end
      # Destiny Bond (recording that it should apply)
      if target.effects[PBEffects::DestinyBond] && target.fainted?
        if user.effects[PBEffects::DestinyBondTarget]<0
          user.effects[PBEffects::DestinyBondTarget] = target.index
        end
      end
    end
  =begin
    alias _ZUD_pbSuccessCheckAgainstTarget pbSuccessCheckAgainstTarget
    def pbSuccessCheckAgainstTarget(*args)
      return true if _ZUD_SuccessCheck(*args) && _ZUD_pbSuccessCheckAgainstTarget(*args)
      return false
    end
  =end
  end
  
  #===============================================================================
  # Checks for the effects of certain Z-Move.
  #===============================================================================
  class PokeBattle_Battle
    #-----------------------------------------------------------------------------
    # Switch-in effect of certain Z-Moves.
    # Must be added to def pbOnActiveOne.
    #-----------------------------------------------------------------------------
    def _ZUD_OnActiveEffects(battler)
      # Z-Parting Shot/Z-Memento
      if @positions[battler.index].effects[PBEffects::ZHeal]
        pbCommonAnimation("HealingWish",battler)
        pbDisplay(_INTL("The Z-Power healed {1}!",battler.pbThis))
        battler.pbRecoverHP(battler.totalhp)
        @positions[battler.index].effects[PBEffects::ZHeal] = false
      end
    end
  end
  
  #===============================================================================
  # The core battle mechanics for utilizing ZUD functions in battle.
  #===============================================================================
  class PokeBattle_ActiveSide
    #-----------------------------------------------------------------------------
    # Initializes effects for a battler's side.
    #-----------------------------------------------------------------------------
    alias _ZUD_initialize initialize  
    def initialize
      _ZUD_initialize
      @effects[PBEffects::ZHeal]      = false
    end
  end
  
  #===============================================================================
  # Triggering and using each mechanic during battle.
  #===============================================================================
  class PokeBattle_Battle
    attr_accessor :zMove, :ultraBurst
  
    #-----------------------------------------------------------------------------
    # Initializes each battle mechanic.
    #-----------------------------------------------------------------------------
    alias _ZUD_initialize initialize
    def initialize(*args)
      _ZUD_initialize(*args)
      @zMove             = [
         [-1] * (@player ? @player.length : 1),
         [-1] * (@opponent ? @opponent.length : 1)
      ]
      @ultraBurst        = [
         [-1] * (@player ? @player.length : 1),
         [-1] * (@opponent ? @opponent.length : 1)
      ]
    end
    
    #-----------------------------------------------------------------------------
    # Checks for items required to utilize certain battle mechanics.
    #-----------------------------------------------------------------------------
    def pbHasZRing?(idxBattler)
      return true if !pbOwnedByPlayer?(idxBattler)
      Settings::Z_RINGS.each { |item| return true if $PokemonBag.pbHasItem?(item) }
      return false
    end
    
    #-----------------------------------------------------------------------------
    # Eligibility checks.
    #-----------------------------------------------------------------------------
    alias _ZUD_pbCanMegaEvolve? pbCanMegaEvolve?
    def pbCanMegaEvolve?(idxBattler)
      return false if pbCanZMove?(idxBattler)
      _ZUD_pbCanMegaEvolve?(idxBattler)
    end
    
    def pbCanZMove?(idxBattler)
      battler = @battlers[idxBattler]
      side    = battler.idxOwnSide
      owner   = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      return false if $game_switches[Settings::NO_Z_MOVE]      # No Z-Moves if switch enabled.
      return false if !battler.hasZMove?                       # No Z-Moves if ineligible.
      return false if battler.hasUltra?                        # No Z-Moves if Ultra Burst is available first.
      return false if wildBattle? && opposes?(idxBattler)      # No Z-Moves for wild Pokemon.
      return true if $DEBUG && Input.press?(Input::CTRL)       # Allows Z-Moves with CTRL in Debug.
      return false if battler.effects[PBEffects::SkyDrop]>=0   # No Z-Moves if in Sky Drop.
      return false if @zMove[side][owner]!=-1                  # No Z-Moves if used this battle.
      return false if !pbHasZRing?(idxBattler)                 # No Z-Moves if no Z-Ring.
      return @zMove[side][owner]==-1
    end
    
    def pbCanUltraBurst?(idxBattler)
      battler = @battlers[idxBattler]
      side  = battler.idxOwnSide
      owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      return false if $game_switches[Settings::NO_ULTRA_BURST] # No Ultra Burst if switch enabled.
      return false if !battler.hasUltra?                       # No Ultra Burst if ineligible.
      return false if wildBattle? && opposes?(idxBattler)      # No Ultra Burst for wild Pokemon.
      return true if $DEBUG && Input.press?(Input::CTRL)       # Allows Ultra Burst with CTRL in Debug.
      return false if battler.effects[PBEffects::SkyDrop]>=0   # No Ultra Burst if in Sky Drop.
      return false if @ultraBurst[side][owner]!=-1             # No Ultra Burst if used this battle.
      return false if !pbHasZRing?(idxBattler)                 # No Ultra Burst if no Z-Ring.
      return @ultraBurst[side][owner]==-1
    end
    
    # Returns true if any battle mechanic is available to the user.
    def pbCanUseBattleMechanic?(idxBattler)
      return true if pbCanMegaEvolve?(idxBattler) ||
                     pbCanZMove?(idxBattler) ||
                     pbCanUltraBurst?(idxBattler)
      return false
    end
    
    #-----------------------------------------------------------------------------
    # Uses the eligible battle mechanic.
    #-----------------------------------------------------------------------------
    def pbUseZMove(idxBattler,move,crystal)
      battler = @battlers[idxBattler]
      return if !battler || !battler.pokemon
      return if !battler.hasZMove?
      the_zmove = PokeBattle_ZMove.from_base_move(self,battler,move,crystal)
      the_zmove.pbUse(battler, nil, false)
    end
    
    def pbUltraBurst(idxBattler)
      battler = @battlers[idxBattler]
      return if !battler || !battler.pokemon
      return if !battler.hasUltra? || battler.ultra?
      pbDisplay(_INTL("Bright light is about to burst out of {1}!",battler.pbThis(true)))    
      pbCommonAnimation("UltraBurst",battler)
      battler.pokemon.makeUltra
      battler.form = battler.pokemon.form
      battler.pbUpdate(true)
      @scene.pbChangePokemon(battler,battler.pokemon)
      @scene.pbRefreshOne(idxBattler)
      pbCommonAnimation("UltraBurst2",battler)
      pbDisplay(_INTL("{1} regained its true power with Ultra Burst!",battler.pbThis))    
      side  = battler.idxOwnSide
      owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      @ultraBurst[side][owner] = -2
      pbCalculatePriority(false,[idxBattler]) if Settings::RECALCULATE_TURN_ORDER_AFTER_MEGA_EVOLUTION
      battler.pbEffectsOnSwitchIn
    end
    
    #-----------------------------------------------------------------------------
    # Registering Z-Moves.
    #-----------------------------------------------------------------------------
    def pbRegisterZMove(idxBattler)
      side  = @battlers[idxBattler].idxOwnSide
      owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      @zMove[side][owner] = idxBattler
    end
    
    def pbUnregisterZMove(idxBattler)
      side  = @battlers[idxBattler].idxOwnSide
      owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      @zMove[side][owner] = -1 if @zMove[side][owner]==idxBattler
    end
  
    def pbToggleRegisteredZMove(idxBattler)
      side  = @battlers[idxBattler].idxOwnSide
      owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      if @zMove[side][owner]==idxBattler
        @zMove[side][owner] = -1
      else
        @zMove[side][owner] = idxBattler
      end
    end
    
    def pbRegisteredZMove?(idxBattler)
      side  = @battlers[idxBattler].idxOwnSide
      owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      return @zMove[side][owner]==idxBattler
    end
    
    #-----------------------------------------------------------------------------
    # Registering Ultra Burst.
    #-----------------------------------------------------------------------------
    def pbRegisterUltraBurst(idxBattler)
      side  = @battlers[idxBattler].idxOwnSide
      owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      @ultraBurst[side][owner] = idxBattler
    end
    
    def pbUnregisterUltraBurst(idxBattler)
      side  = @battlers[idxBattler].idxOwnSide
      owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      @ultraBurst[side][owner] = -1 if @ultraBurst[side][owner]==idxBattler
    end
  
    def pbToggleRegisteredUltraBurst(idxBattler)
      side  = @battlers[idxBattler].idxOwnSide
      owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      if @ultraBurst[side][owner]==idxBattler
        @ultraBurst[side][owner] = -1
      else
        @ultraBurst[side][owner] = idxBattler
      end
    end
    
    def pbRegisteredUltraBurst?(idxBattler)
      side  = @battlers[idxBattler].idxOwnSide
      owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      return @ultraBurst[side][owner]==idxBattler
    end
    
    #-----------------------------------------------------------------------------
    # Triggers the use of each battle mechanic during the attack phase.
    #-----------------------------------------------------------------------------
    def pbAttackPhase
      @scene.pbBeginAttackPhase
      @battlers.each_with_index do |b,i|
        next if !b
        b.turnCount += 1 if !b.fainted?
        @successStates[i].clear
        if @choices[i][0]!=:UseMove && @choices[i][0]!=:Shift && @choices[i][0]!=:SwitchOut
          b.effects[PBEffects::DestinyBond] = false
          b.effects[PBEffects::Grudge]      = false
        end
        b.effects[PBEffects::Rage] = false if !pbChoseMoveFunctionCode?(i,"093")
      end
      #---------------------------------------------------------------------------
      # Prepare for Z-Moves.
      #---------------------------------------------------------------------------
      @battlers.each_with_index do |b,i|
        next if !b || b.fainted?
        next if @choices[i][0]!=:UseMove
        side  = (opposes?(i)) ? 1 : 0
        owner = pbGetOwnerIndexFromBattlerIndex(i)
        @choices[i][2].zmove_sel = (@zMove[side][owner]==i)
      end
      #---------------------------------------------------------------------------
      PBDebug.log("")
      pbCalculatePriority(true)
      pbAttackPhasePriorityChangeMessages
      pbAttackPhaseCall
      pbAttackPhaseSwitch
      return if @decision>0
      pbAttackPhaseItems
      return if @decision>0
      pbAttackPhaseMegaEvolution
      pbAttackPhaseUltraBurst
      pbAttackPhaseZMoves
      pbAttackPhaseMoves
    end
    
    def pbAttackPhaseZMoves
      pbPriority.each do |b|
        idxMove = @choices[b.index]
        next if wildBattle? && b.opposes?
        next unless @choices[b.index][0]==:UseMove && !b.fainted?
        owner = pbGetOwnerIndexFromBattlerIndex(b.index)
        next if @zMove[b.idxOwnSide][owner]!=b.index
        @choices[b.index][2].zmove_sel = true
      end
    end
    
    def pbAttackPhaseUltraBurst
      pbPriority.each do |b|
        next if wildBattle? && b.opposes?
        next unless @choices[b.index][0]==:UseMove && !b.fainted?
        owner = pbGetOwnerIndexFromBattlerIndex(b.index)
        next if @ultraBurst[b.idxOwnSide][owner]!= b.index
        pbUltraBurst(b.index)
      end
    end
  end
  #===============================================================================
  # Command Phase
  #===============================================================================
  class PokeBattle_Battle
    #-----------------------------------------------------------------------------
    # Pokemon with an eligible battle mechanic may always access its fight menu,
    # even if the effects of Encore would otherwise lock them out.
    #-----------------------------------------------------------------------------
    def pbCanShowFightMenu?(idxBattler)
      battler = @battlers[idxBattler]
      # Restores the user's Encore status after a Z-Move was used.
      if battler.effects[PBEffects::EncoreRestore]
        battler.effects[PBEffects::Encore]        = battler.effects[PBEffects::EncoreRestore][0]
        battler.effects[PBEffects::EncoreMove]    = battler.effects[PBEffects::EncoreRestore][1]
        battler.effects[PBEffects::EncoreRestore] = nil
      end
      return false if battler.effects[PBEffects::Encore]>0 && !pbCanUseBattleMechanic?(idxBattler)
      usable = false
      battler.eachMoveWithIndex do |_m,i|
        next if !pbCanChooseMove?(idxBattler,i,false)
        usable = true
        break
      end
      return usable
    end
    
    #-----------------------------------------------------------------------------
    # Message display when an Encored move is selected in the fight menu.
    #-----------------------------------------------------------------------------
    def pbCanChooseMove?(idxBattler,idxMove,showMessages,sleepTalk=false)
      battler = @battlers[idxBattler]
      move = battler.moves[idxMove]
      return false unless move
      if move.pp==0 && move.total_pp>0 && !sleepTalk
        pbDisplayPaused(_INTL("There's no PP left for this move!")) if showMessages
        return false
      end
      if battler.effects[PBEffects::Encore]>0
        idxEncoredMove = battler.pbEncoredMoveIndex
        if idxEncoredMove>=0 && idxMove!=idxEncoredMove && !move.powerMove?
          pbDisplayPaused(_INTL("Encore prevents using this move!")) if showMessages
          return false 
        end 
      end
      return battler.pbCanChooseMove?(move,true,showMessages,sleepTalk)
    end
    
    #-----------------------------------------------------------------------------
    # Unregisters mechanics and returns to base moves when a choice is cancelled.
    #-----------------------------------------------------------------------------
    def pbCancelChoice(idxBattler)
      if @choices[idxBattler][0]==:UseItem
        item = @choices[idxBattler][1]
        pbReturnUnusedItemToBag(item,idxBattler) if item
      end
      pbUnregisterMegaEvolution(idxBattler)
      pbUnregisterUltraBurst(idxBattler)
      if pbRegisteredZMove?(idxBattler)
        pbUnregisterZMove(idxBattler)
        @battlers[idxBattler].effects[PBEffects::PowerMovesButton] = false
        @battlers[idxBattler].pbDisplayBaseMoves
      end
      pbClearChoice(idxBattler)
    end
    
    #-----------------------------------------------------------------------------
    # Registers battle mechanics when triggered in the fight menu.
    #-----------------------------------------------------------------------------
    def pbFightMenu(idxBattler)
      return pbAutoChooseMove(idxBattler) if !pbCanShowFightMenu?(idxBattler)
      return true if pbAutoFightMenu(idxBattler)
      ret = false
      @scene.pbFightMenu(idxBattler,pbCanMegaEvolve?(idxBattler),
                                    pbCanUltraBurst?(idxBattler),
                                    pbCanZMove?(idxBattler)
                                    ) { |cmd|
        case cmd
        when -1   # Cancel
        when -2   # Mega Evolution
          pbToggleRegisteredMegaEvolution(idxBattler)
          next false
        when -3   # Ultra Burst
          pbToggleRegisteredUltraBurst(idxBattler)
          next false
        when -4   # Z-Moves
          pbToggleRegisteredZMove(idxBattler)
          next false
        when -6   # Shift
          pbUnregisterMegaEvolution(idxBattler)
          pbUnregisterUltraBurst(idxBattler)
          pbUnregisterZMove(idxBattler)
          @battlers[idxBattler].effects[PBEffects::PowerMovesButton] = false
          @battlers[idxBattler].pbDisplayBaseMoves
          pbRegisterShift(idxBattler)
          ret = true
        else
          next false if cmd<0 || !@battlers[idxBattler].moves[cmd] ||
                                 !@battlers[idxBattler].moves[cmd].id
          next false if !pbRegisterMove(idxBattler,cmd)
          next false if !singleBattle? &&
             !pbChooseTarget(@battlers[idxBattler],@battlers[idxBattler].moves[cmd])
          ret = true
        end
        next true
      }
      return ret
    end
  end
  
  #===============================================================================
  # Applies the effects of a registered battle mechanic when toggled in the menu.
  #===============================================================================
  class PokeBattle_Scene
    def pbFightMenu(idxBattler,megaEvoPossible = false,
                               ultraPossible   = false,
                               zMovePossible   = false
                               )
                               
      battler = @battle.battlers[idxBattler]
      cw = @sprites["fightWindow"]
      cw.battler = battler
      moveIndex  = 0
      if battler.moves[@lastMove[idxBattler]] && battler.moves[@lastMove[idxBattler]].id
        moveIndex = @lastMove[idxBattler]
      end
      cw.shiftMode = (@battle.pbCanShift?(idxBattler)) ? 1 : 0
      mechanicPossible = false
      cw.chosen_button = FightMenuDisplay::NoButton
      cw.chosen_button = FightMenuDisplay::MegaButton       if megaEvoPossible
      cw.chosen_button = FightMenuDisplay::UltraBurstButton if ultraPossible
      cw.chosen_button = FightMenuDisplay::ZMoveButton      if zMovePossible
      if megaEvoPossible || ultraPossible || 
         zMovePossible
        mechanicPossible = true
      end
      cw.setIndexAndMode(moveIndex,(mechanicPossible) ? 1 : 0)
      needFullRefresh = true
      needRefresh = false
      loop do
        if needFullRefresh
          pbShowWindow(FIGHT_BOX)
          pbSelectBattler(idxBattler)
          needFullRefresh = false
        end
        if needRefresh
          if megaEvoPossible
            newMode = (@battle.pbRegisteredMegaEvolution?(idxBattler)) ? 2 : 1
            cw.mode = newMode if newMode!=cw.mode
          end
          if ultraPossible
            newMode = (@battle.pbRegisteredUltraBurst?(idxBattler)) ? 2 : 1
            cw.mode = newMode if newMode!=cw.mode
          end
          if zMovePossible
            newMode = (@battle.pbRegisteredZMove?(idxBattler)) ? 2 : 1
            cw.mode = newMode if newMode!=cw.mode
          end
          needRefresh = false
        end
        oldIndex = cw.index
        pbUpdate(cw)
        if Input.trigger?(Input::LEFT)
          cw.index -= 1 if (cw.index&1)==1
        elsif Input.trigger?(Input::RIGHT)
          if battler.moves[cw.index+1] && battler.moves[cw.index+1].id
            cw.index += 1 if (cw.index&1)==0
          end
        elsif Input.trigger?(Input::UP)
          cw.index -= 2 if (cw.index&2)==2
        elsif Input.trigger?(Input::DOWN)
          if battler.moves[cw.index+2] && battler.moves[cw.index+2].id
            cw.index += 2 if (cw.index&2)==0
          end
        end
        pbPlayCursorSE if cw.index!=oldIndex
  #===============================================================================
  # Confirm Selection
  #===============================================================================
        if Input.trigger?(Input::USE)
          #-----------------------------------------------------------------------
          # Z-Moves
          #-----------------------------------------------------------------------
          if zMovePossible
            if cw.mode==2
              itemname = battler.item.name
              movename = battler.moves[cw.index].name
              if !battler.pbCompatibleZMove?(battler.moves[cw.index])
                @battle.pbDisplay(_INTL("{1} is not compatible with {2}!",movename,itemname))
                if battler.effects[PBEffects::PowerMovesButton]
                  battler.effects[PBEffects::PowerMovesButton] = false
                  battler.pbDisplayBaseMoves(1)
                end
                break if yield -1
              end
            end
          end
          battler.effects[PBEffects::PowerMovesButton] = false if ultraPossible
          #-----------------------------------------------------------------------
          pbPlayDecisionSE
          break if yield cw.index
          needFullRefresh = true
          needRefresh = true
  #===============================================================================
  # Cancel Selection
  #===============================================================================
        elsif Input.trigger?(Input::BACK)
          #-----------------------------------------------------------------------
          # Z-Moves - Reverts to base moves.
          #-----------------------------------------------------------------------
          if zMovePossible
            if battler.effects[PBEffects::PowerMovesButton]
              battler.pbDisplayBaseMoves
            end
          end
          #-----------------------------------------------------------------------
          battler.effects[PBEffects::PowerMovesButton] = false
          pbPlayCancelSE
          break if yield -1
          needRefresh = true
  #===============================================================================
  # Toggle Battle Mechanic
  #===============================================================================
        elsif Input.trigger?(Input::ACTION)
          #-----------------------------------------------------------------------
          # Mega Evolution
          #-----------------------------------------------------------------------
          if megaEvoPossible
            pbPlayDecisionSE
            break if yield -2
            needRefresh = true
          end
          #-----------------------------------------------------------------------
          # Z-Moves
          #-----------------------------------------------------------------------
          if zMovePossible
            battler.effects[PBEffects::PowerMovesButton] = !battler.effects[PBEffects::PowerMovesButton]
            if battler.effects[PBEffects::PowerMovesButton]
              battler.pbDisplayPowerMoves(1)
              pbPlayZUDButton
            else
              battler.pbDisplayBaseMoves
              pbPlayCancelSE
            end
            needFullRefresh = true
            break if yield -4
            needRefresh = true
          end
          #-----------------------------------------------------------------------
          # Ultra Burst
          #-----------------------------------------------------------------------
          if ultraPossible
            battler.effects[PBEffects::PowerMovesButton] = !battler.effects[PBEffects::PowerMovesButton]
            if battler.effects[PBEffects::PowerMovesButton]
              pbPlayZUDButton
            else
              pbPlayCancelSE
            end
            break if yield -3
            needRefresh = true
          end
  #===============================================================================
  # Shift Command
  #===============================================================================
        elsif Input.trigger?(Input::SPECIAL)
          if cw.shiftMode>0
            pbPlayDecisionSE
            break if yield -6
            needRefresh = true
          end
        end
      end
      @lastMove[idxBattler] = cw.index
    end
  end