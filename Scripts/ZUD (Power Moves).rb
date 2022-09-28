#===============================================================================
# PokeBattle_ZMove child class
#===============================================================================
class PokeBattle_ZMove < PokeBattle_Move
    attr_reader :oldmove, :oldname, :status
  
    def initialize(battle, move, newMove)
      validate move => PokeBattle_Move
      super(battle, newMove)
      @oldmove    = move
      @status     = @oldmove.statusMove?
      newMove_cat = GameData::Move.get(newMove.id).category
      @category   = (newMove_cat==2) ? 2 : move.category
      @baseDamage = pbZMoveBaseDamage(move) if @baseDamage==1 && @category<2
      @oldname    = move.name
      if @status
        @flags    + "z" if !zMove?
        @name     = "Z-" + move.name
        @oldmove.name = @name
      end 
      @short_name = (@name.length > 15 && Settings::SHORTEN_MOVES) ? @name[0..12] + "..." : @name
    end
    
    #-----------------------------------------------------------------------------
    # Gets a battler's Z-Move based on the inputted move and Z-Crystal.
    #-----------------------------------------------------------------------------
    def PokeBattle_ZMove.from_base_move(battle, battler, move, item)
      return move if move.is_a?(PokeBattle_ZMove)
      newpoke   = battler.effects[PBEffects::TransformPokemon]
      pokemon   = battler.effects[PBEffects::Transform] ? newpoke : battler.pokemon
      #z_compat  = pokemon.compat_zmove?(move)
      z_compat  = pokemon.compat_zmove?(move,item)
      newMove   = nil
      if !z_compat || move.statusMove?
        newMove    = Pokemon::Move.new(move.id)
        newMove.pp = 1 
        return PokeBattle_ZMove.new(battle, move, newMove)
      end
      #z_move_id    = pokemon.get_zmove(move)
      z_move_id    = pokemon.get_zmove(move,item)
      newMove      = Pokemon::Move.new(z_move_id)
      moveFunction = newMove.function_code || "Z000"
      className    = sprintf("PokeBattle_Move_%s",moveFunction)
      if Object.const_defined?(className)
        return Object.const_get(className).new(battle, move, newMove)
      end
      return PokeBattle_ZMove.new(battle, move, newMove)
    end
    
    #-----------------------------------------------------------------------------
    # Uses a Z-Move. Status moves have the Z-Move flag added to them.
    #-----------------------------------------------------------------------------
    def pbUse(battler, simplechoice=nil, specialUsage=false)
      battler.pbBeginTurn(self)
      zchoice = @battle.choices[battler.index]
      if simplechoice
        zchoice = simplechoice
      end
      @specialUseZMove = specialUsage
      # Targeted status Z-Moves here.
      if @status
        oldpkmn    = battler.pokemon
        zchoice[2] = @oldmove
        oldflags   = zchoice[2].flags
        zchoice[2].flags = oldflags + "z"
        battler.pbUseMove(zchoice, specialUsage)
        if !battler.fainted? && battler.pokemon==oldpkmn
          zchoice[2].flags = oldflags
          @oldmove.name = @oldname
        end
      else
        zchoice[2] = self
        battler.pbUseMove(zchoice, specialUsage)
        battler.pbReducePPOther(@oldmove)
      end
    end
    
    #-----------------------------------------------------------------------------
    # Protection moves don't fully negate Z-Moves.
    #-----------------------------------------------------------------------------
    def pbModifyDamage(damageMult, user, target)
      if target.effects[PBEffects::Protect] || 
         target.effects[PBEffects::KingsShield] ||
         target.effects[PBEffects::SpikyShield] ||
         target.effects[PBEffects::BanefulBunker] ||
         target.pbOwnSide.effects[PBEffects::MatBlock] ||
         (GameData::Move.exists?(:OBSTRUCT) && target.effects[PBEffects::Obstruct])
        @battle.pbDisplay(_INTL("{1} couldn't fully protect itself!",target.pbThis))
        return damageMult/4
      else      
        return damageMult
      end    
    end
    
    #-----------------------------------------------------------------------------
    # Abilities that change move type aren't triggered by Z-Moves.
    #-----------------------------------------------------------------------------
    def pbBaseType(user)
      return @type if !@status
      return super(user)
    end
    
    #=============================================================================
    # Converts move's power into Z-Move power.
    #=============================================================================
    def pbZMoveBaseDamage(oldmove)
      if @status
        return 0
      #---------------------------------------------------------------------------
      # Becomes Z-Move with 180 BP (OHKO moves).
      #---------------------------------------------------------------------------
      elsif oldmove.function == "070"
        return 180 
      end 
      #---------------------------------------------------------------------------
      # Specific moves with specific values.
      #--------------------------------------------------------------------------- 
      case @oldmove.id
      when :MEGADRAIN
        return 120
      when :WEATHERBALL  
        return 160
      when :HEX
        return 160
      when :GEARGRIND  
        return 180
      when :VCREATE
        return 220
      when :FLYINGPRESS
        return 170
      when :COREENFORCER
        return 140
      end 
      #---------------------------------------------------------------------------
      # All other moves scale based on their BP.
      #---------------------------------------------------------------------------
      check = @oldmove.baseDamage
      if check <56
        return 100
      elsif check <66
        return 120
      elsif check <76
        return 140
      elsif check <86
        return 160
      elsif check <96
        return 175
      elsif check <101
        return 180
      elsif check <111
        return 185
      elsif check <126
        return 190
      elsif check <131
        return 195
      else
        return 200
      end
    end
    
    #=============================================================================
    # Effects for status Z-Moves.
    #=============================================================================
    def PokeBattle_ZMove.from_status_move(battle, move, attacker)
      # Curse changes its effect if the user is Ghost type or not.
      curseZMoveGhost    = (move==:CURSE && attacker.pbHasType?(:GHOST))
      curseZMoveNonGhost = (move==:CURSE && !attacker.pbHasType?(:GHOST))
      #---------------------------------------------------------------------------
      # Effects for status Z-Moves that boost the stats of the user.
      #---------------------------------------------------------------------------
      if GameData::PowerMove.stat_booster?(move) || curseZMoveNonGhost
        stats, stage = GameData::PowerMove.stat_with_stage(move)
        stats, stage = [:ATTACK], 1 if curseZMoveNonGhost 
        statname = (stats.length>1) ? "stats" : GameData::Stat.get(stats[0]).name
        case stage
        when 3; boost = " drastically"
        when 2; boost = " sharply"
        else;   boost = ""
        end
        showAnim = true
        for i in 0...stats.length
          if attacker.pbCanRaiseStatStage?(stats[i],attacker)
            attacker.pbRaiseStatStageBasic(stats[i],stage)
            if showAnim
              battle.pbCommonAnimation("StatUp",attacker)
              battle.pbDisplayBrief(_INTL("{1} boosted its {2}{3} using its Z-Power!",attacker.pbThis,statname,boost))
            end
            showAnim = false
          end
        end
      #---------------------------------------------------------------------------
      # Effect for status Z-Moves that boosts the user's critical hit ratio.
      #---------------------------------------------------------------------------
      elsif GameData::PowerMove.boosts_crit?(move)
        attacker.effects[PBEffects::CriticalBoost] += 2
        battle.pbDisplayBrief(_INTL("{1} boosted its critical hit ratio using its Z-Power!",attacker.pbThis))
      #---------------------------------------------------------------------------
      # Effect for status Z-Moves that resets the user's lowered stats.
      #---------------------------------------------------------------------------
      elsif GameData::PowerMove.resets_stats?(move) && attacker.hasLoweredStatStages?
        attacker.pbResetStatStages
        battle.pbDisplayBrief(_INTL("{1} returned its decreased stats to normal using its Z-Power!",attacker.pbThis))
      #---------------------------------------------------------------------------
      # Effects for status Z-Moves that heal HP.
      #---------------------------------------------------------------------------
      elsif GameData::PowerMove.heals_self?(move) || curseZMoveGhost
        if attacker.hp<attacker.totalhp
          attacker.pbRecoverHP(attacker.totalhp,false)
          battle.pbDisplayBrief(_INTL("{1} restored its HP using its Z-Power!",attacker.pbThis))
        end
      elsif GameData::PowerMove.heals_switch?(move)
        battle.positions[attacker.index].effects[PBEffects::ZHeal] = true
      #---------------------------------------------------------------------------
      # Z-Status moves that cause misdirection.
      #---------------------------------------------------------------------------
      elsif GameData::PowerMove.focus_user?(move)
        battle.pbDisplayBrief(_INTL("{1} became the center of attention using its Z-Power!",attacker.pbThis))
        attacker.effects[PBEffects::FollowMe] = 1
        attacker.eachAlly do |b|
          next if b.effects[PBEffects::FollowMe]<attacker.effects[PBEffects::FollowMe]
          attacker.effects[PBEffects::FollowMe] = b.effects[PBEffects::FollowMe]+1
        end
      end
    end
  end
  
  #===============================================================================
  # Move Effects for Z-Moves.
  #===============================================================================
  
  #===============================================================================
  # Generic Z-Move classes.
  #===============================================================================
  # Raises all of the user's stats.
  #-------------------------------------------------------------------------------
  class PokeBattle_ZMove_AllStatsUp < PokeBattle_ZMove
    def initialize(battle,move,newMove)
      super
      @statUp = []
    end
    
    def pbMoveFailed?(user,targets)
      return false if damagingMove?
      failed = true
      for i in 0...@statUp.length/2
        next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
        failed = false
        break
      end
      if failed
        @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",user.pbThis))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      return if damagingMove?
      showAnim = true
      for i in 0...@statUp.length/2
        next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
        if user.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
          showAnim = false
        end
      end
    end
  
    def pbAdditionalEffect(user,target)
      showAnim = true
      for i in 0...@statUp.length/2
        next if !user.pbCanRaiseStatStage?(@statUp[i*2],user,self)
        if user.pbRaiseStatStage(@statUp[i*2],@statUp[i*2+1],user,showAnim)
          showAnim = false
        end
      end
    end
  end
  
  #===============================================================================
  # Generic Z-Moves
  #===============================================================================
  # No effect.
  #-------------------------------------------------------------------------------
  class PokeBattle_Move_Z000 < PokeBattle_ZMove
  end
  
  #===============================================================================
  # Stoked Sparksurfer
  #===============================================================================
  # Inflicts paralysis.
  #-------------------------------------------------------------------------------
  class PokeBattle_Move_Z001 < PokeBattle_ZMove
    def initialize(battle,move,newMove)
      super
    end
  
    def pbFailsAgainstTarget?(user,target)
      return false if damagingMove?
      return !target.pbCanParalyze?(user,true,self)
    end
  
    def pbEffectAgainstTarget(user,target)
      return if damagingMove?
      target.pbParalyze(user)
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
    end
  end 
  
  #===============================================================================
  # Malicious Moonsault
  #===============================================================================
  # Doubles damage on minimized Pokémon.
  #-------------------------------------------------------------------------------
  class PokeBattle_Move_Z002 < PokeBattle_ZMove
    def tramplesMinimize?(param=1)
      # Perfect accuracy and double damage if minimized
      return MECHANICS_GENERATION >= 7
    end
  end 
  
  #===============================================================================
  # Extreme Evoboost
  #===============================================================================
  # Raises all stats by 2 stages.
  #-------------------------------------------------------------------------------
  class PokeBattle_Move_Z003 < PokeBattle_ZMove_AllStatsUp
    def initialize(battle,move,newMove)
      super
      if $fefieldeffect == 9
        increment = 4
      elsif [29,34].include?($fefieldeffect)
        increment = 3
      else
        increment = 2
      end
      @statUp = [:ATTACK,increment,:DEFENSE,increment,:SPECIAL_ATTACK,increment,:SPECIAL_DEFENSE,
                increment,:SPEED,increment]
    end
  end 
  
  #===============================================================================
  # Genesis Supernova
  #===============================================================================
  # Sets Psychic Terrain.
  #-------------------------------------------------------------------------------
  class PokeBattle_Move_Z004 < PokeBattle_ZMove
    def pbAdditionalEffect(user,target)
      if (@battle.field.effects[PBEffects::FEDuration] > 0 || $fefieldeffect == 0) &&
         ![35,37].include?($fefieldeffect)
        @battle.changeField(37,"Mysterious energy spread throughout the battlefield!",5,user.hasTerrainExtender?,true)
      end
    end
  end 
  
  #===============================================================================
  # Guardian of Alola
  #===============================================================================
  # Inflicts 75% of the target's current HP.
  #-------------------------------------------------------------------------------
  class PokeBattle_Move_Z005 < PokeBattle_ZMove
    def pbFixedDamage(user,target)
      return (target.hp*0.75).round
    end
    
    def pbCalcDamage(user,target,numTargets=1)
      target.damageState.critical   = false
      target.damageState.calcDamage = pbFixedDamage(user,target)
      target.damageState.calcDamage = 1 if target.damageState.calcDamage<1
    end
    
    def pbEffectAfterAllHits(user,target)
      if $fefieldeffect == 2
        user.pbRaiseStatStage(:SPECIAL_DEFENSE,2,user)
      elsif $fefieldeffect == 15
        user.pbRaiseStatStage([:DEFENSE,:SPECIAL_DEFENSE],1,user)
      elsif [29,31].include?($fefieldeffect)
        user.effects[PBEffects::Protect]=true
        @battle.pbAnimation(:PROTECT,user,nil)
        @battle.pbDisplay(_INTL("{1} shielded itself against damage!",user.pbThis))
      end
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      case user.species
      when :TAPUFINI
        hitNum = 1
      when :TAPUKOKO
        hitNum = 2
      when :TAPULELE
        hitNum = 3
      end # Tapu Bulu default
      super
    end
  end
  
  #===============================================================================
  # Menacing Moonraze Maelstrom, Searing Sunraze Smash
  #===============================================================================
  # Ignores ability.
  #-------------------------------------------------------------------------------
  class PokeBattle_Move_Z006 < PokeBattle_ZMove
    def pbChangeUsageCounters(user,specialUsage)
      super
      @battle.moldBreaker = true if !specialUsage
    end
  end 
  
  #===============================================================================
  # Splintered Stormshards
  #===============================================================================
  # Removes terrains.
  #-------------------------------------------------------------------------------
  class PokeBattle_Move_Z007 < PokeBattle_ZMove
    def pbAdditionalEffect(user,target)
      @battle.changeField($febackup,"The terrain returned to normal.")
    end
  end 
  
  #===============================================================================
  # Light That Burns the Sky
  #===============================================================================
  # Ignores ability + is physical or special depending on what's best. 
  #-------------------------------------------------------------------------------
  #class PokeBattle_Move_Z008 < PokeBattle_Move_Z007
  class PokeBattle_Move_Z008 < PokeBattle_ZMove
    def initialize(battle,move,newMove)
      super
      @calcCategory = 1
    end
  
    def physicalMove?(thisType=nil); return (@calcCategory==0); end
    def specialMove?(thisType=nil);  return (@calcCategory==1); end
      
    def pbChangeUsageCounters(user,specialUsage)
      super
      @battle.moldBreaker = true if !specialUsage
    end
  
    def pbOnStartUse(user,targets)
      # Calculate user's effective attacking value
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      atk        = user.attack
      atkStage   = user.stages[:ATTACK]+6
      realAtk    = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
      spAtk      = user.spatk
      spAtkStage = user.stages[:SPECIAL_ATTACK]+6
      realSpAtk  = (spAtk.to_f*stageMul[spAtkStage]/stageDiv[spAtkStage]).floor
      # Determine move's category
      @calcCategory = (realAtk>realSpAtk) ? 0 : 1
    end
  end
  
  #===============================================================================
  # Clangorous Soulblaze
  #===============================================================================
  # Raises all stats by 1 stage.
  #-------------------------------------------------------------------------------
  class PokeBattle_Move_Z009 < PokeBattle_ZMove_AllStatsUp
    def initialize(battle,move,newMove)
      super
      @statUp = [:ATTACK,1,:DEFENSE,1,:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1,:SPEED,1]
      if $fefieldeffect == 32
        @statUp = [:ATTACK,2,:DEFENSE,2,:SPECIAL_ATTACK,2,:SPECIAL_DEFENSE,2,:SPEED,2]
      end
    end
  end 
  
  #===============================================================================
  # Shattered Psyche
  #===============================================================================
  # Confuses the target in Psychic Terrain
  #-------------------------------------------------------------------------------
  class PokeBattle_Move_Z010 < PokeBattle_ZMove
    def pbAdditionalEffect(user,target)
      return if $fefieldeffect != 37
      return if target.damageState.substitute
      return if !target.pbCanConfuse?(user,false,self)
      target.pbConfuse
    end
  end 