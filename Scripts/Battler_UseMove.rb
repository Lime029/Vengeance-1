class PokeBattle_Battler
    #=============================================================================
    # Turn processing
    #=============================================================================
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
        # Move Memory Tracker
        if !@pokemon.moveMemory.include?(choice[2]) && choice[2].statusMove? # Status moves display the name of the original, but otherwise not
          @pokemon.moveMemory.push(choice[2])
          echo("\n[AI - #{Time.now - $time}] #{pbThis}'s #{choice[2].name} was added to its move memory.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
        @battle.pbUseZMove(self.index,choice[2],self.item)
      else
        PBDebug.log("[Move usage] #{pbThis} started using #{choice[2].name}") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        # Move Memory Tracker
        if !@pokemon.moveMemory.include?(choice[2])
          @pokemon.moveMemory.push(choice[2])
          echo("\n[AI - #{Time.now - $time}] #{pbThis}'s #{choice[2].name} was added to its move memory.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
        PBDebug.logonerr{pbUseMove(choice,choice[2]==@battle.struggle)}
      end
      @battle.pbJudge
      @battle.pbCalculatePriority if Settings::RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES
      @effects[PBEffects::AlwaysMiss] = -1
      @effects[PBEffects::NeverMiss] = false
      @effects[PBEffects::TracedMove] = false
      @effects[PBEffects::AlreadyHitEffect] = false
      @effects[PBEffects::Performer] = 0
      return true
    end
    #=============================================================================
    #
    #=============================================================================
    def pbBeginTurn(_choice)
      # Cancel some lingering effects which only apply until the user next moves
      @effects[PBEffects::DestinyBondPrevious] = @effects[PBEffects::DestinyBond]
      @effects[PBEffects::DestinyBond]         = false
      @effects[PBEffects::Grudge]              = false
      @effects[PBEffects::MoveNext]            = false
      @effects[PBEffects::Quash]               = 0
      # Encore's effect ends if the encored move is no longer available
      if @effects[PBEffects::Encore]>0 && pbEncoredMoveIndex<0
        @effects[PBEffects::Encore]     = 0
        @effects[PBEffects::EncoreMove] = nil
      end
    end
  
    # Called when the usage of various multi-turn moves is disrupted due to
    # failing pbTryUseMove, being ineffective against all targets, or because
    # Pursuit was used specially to intercept a switching foe.
    # Cancels the use of multi-turn moves and counters thereof. Note that Hyper
    # Beam's effect is NOT cancelled.
    def pbCancelMoves(full_cancel = false)
      # Outragers get confused anyway if they are disrupted during their final
      # turn of using the move
      if @effects[PBEffects::Outrage]==1 && pbCanConfuseSelf?(false) && !full_cancel
        pbConfuse(_INTL("{1} became confused due to fatigue!",pbThis))
      end
      # Cancel usage of most multi-turn moves
      @effects[PBEffects::TwoTurnAttack] = nil
      @effects[PBEffects::Rollout]       = 0
      @effects[PBEffects::Outrage]       = 0
      @effects[PBEffects::Uproar]        = 0
      @effects[PBEffects::Bide]          = 0
      @currentMove = nil
      # Reset counters for moves which increase them when used in succession
      @effects[PBEffects::FuryCutter]    = 0
    end
  
    def pbEndTurn(_choice)
      @lastRoundMoved = @battle.turnCount   # Done something this round
      # Gorilla Tactics
      if !@effects[PBEffects::GorillaTactics] && hasActiveAbility?(:GORILLATACTICS) &&
         ![12,29,44,49].include?($fefieldeffect)
        if @lastMoveUsed && pbHasMove?(@lastMoveUsed)
          @effects[PBEffects::GorillaTactics] = @lastMoveUsed
        elsif @lastRegularMoveUsed && pbHasMove?(@lastRegularMoveUsed)
          @effects[PBEffects::GorillaTactics] = @lastRegularMoveUsed
        end
      end
      if !@effects[PBEffects::ChoiceBand] &&
         hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF,:CHOICEDUMPLING])
        if @lastMoveUsed && pbHasMove?(@lastMoveUsed)
          @effects[PBEffects::ChoiceBand] = @lastMoveUsed
        elsif @lastRegularMoveUsed && pbHasMove?(@lastRegularMoveUsed)
          @effects[PBEffects::ChoiceBand] = @lastRegularMoveUsed
        end
      end
      @effects[PBEffects::BeakBlast]   = false
      @effects[PBEffects::Charge]      = 0 if @effects[PBEffects::Charge]==1
      @effects[PBEffects::GemConsumed] = nil
      @effects[PBEffects::ShellTrap]   = false
      @battle.eachBattler { |b| b.pbContinualAbilityChecks }   # Trace, end primordial weathers
    end
  
    def pbConfusionDamage(msg)
      @damageState.reset
      @damageState.initialHP = @hp
      confusionMove = PokeBattle_Confusion.new(@battle,nil)
      confusionMove.calcTypes = confusionMove.pbCalcTypes(self)   # nil
      @damageState.typeMod = confusionMove.pbCalcTypeMod(confusionMove.calcTypes,self,self)   # 8
      confusionMove.pbCheckDamageAbsorption(self,self)
      confusionMove.pbCalcDamage(self,self)
      confusionMove.pbReduceDamage(self,self)
      self.hp -= @damageState.hpLost
      confusionMove.pbAnimateHitAndHPLost(self,[self])
      @battle.pbDisplay(msg)   # "It hurt itself in its confusion!"
      confusionMove.pbRecordDamageLost(self,self)
      confusionMove.pbEndureKOMessage(self)
      pbFaint if fainted?
      pbItemHPHealCheck
      eachOpposing do |b|
        if b.hasActiveAbility?(:EMOTION)
          b.eachOwnSideBattler do |a|
            a.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,b)
          end
        end
      end
    end
  
    #=============================================================================
    # Simple "use move" method, used when a move calls another move and for Future
    # Sight's attack
    #=============================================================================
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
  
    #=============================================================================
    # Master "use move" method
    #=============================================================================
    def pbUseMove(choice,specialUsage=false)
      $feshutup=0
      $feshutup2=0
      # NOTE: This is intentionally determined before a multi-turn attack can
      #       set specialUsage to true.
      skipAccuracyCheck = (specialUsage && choice[2]!=@battle.struggle)
      # Start using the move
      pbBeginTurn(choice)
      # Force the use of certain moves if they're already being used
      if usingMultiTurnAttack?
        choice[2] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(@currentMove))
        specialUsage = true
      elsif @effects[PBEffects::Encore]>0 && choice[1]>=0 &&
         @battle.pbCanShowCommands?(@index)
        idxEncoredMove = pbEncoredMoveIndex
        if idxEncoredMove>=0 && @battle.pbCanChooseMove?(@index,idxEncoredMove,false)
          if choice[1]!=idxEncoredMove   # Change move if battler was Encored mid-round
            choice[1] = idxEncoredMove
            choice[2] = @moves[idxEncoredMove]
            choice[3] = -1   # No target chosen
          end
        end
      end
      # Labels the move being used as "move"
      move = choice[2]
      return if !move   # if move was not chosen somehow
      # Try to use the move (inc. disobedience)
      @lastMoveFailed = false
      if !pbTryUseMove(choice,move,specialUsage,skipAccuracyCheck)
        @lastMoveUsed      = nil
        @lastMoveUsedType = nil
        if !specialUsage
          @lastRegularMoveUsed   = nil
          @lastRegularMoveTarget = -1
        end
        @battle.pbGainExp   # In case self is KO'd due to confusion
        pbCancelMoves
        pbEndTurn(choice)
        return
      end
      move = choice[2]   # In case disobedience changed the move to be used
      return if !move   # if move was not chosen somehow
      # Subtract PP
      if !specialUsage
        if !pbReducePP(move)
          @battle.pbDisplay(_INTL("{1} used {2}!",pbThis,move.name))
          @battle.pbDisplay(_INTL("But there was no PP left for the move!"))
          @lastMoveUsed          = nil
          @lastMoveUsedType     = nil
          @lastRegularMoveUsed   = nil
          @lastRegularMoveTarget = -1
          @lastMoveFailed        = true
          pbCancelMoves
          pbEndTurn(choice)
          return
        end
      end
      # Stance Change
      if hasActiveAbility?(:STANCECHANGE,false,true) #&& isSpecies?(:AEGISLASH)
        if move.damagingMove?
          if $fefieldeffect == 31
            pbLowerStatStage(:DEFENSE,1)
            pbRaiseStatStage(:ATTACK,1)
          end
          @battle.pbCommonAnimation("StanceAttack",self)
          pbChangeForm(1,_INTL("{1} changed to Blade Forme!",pbThis))
        elsif move.id == :KINGSSHIELD
          if $fefieldeffect == 31
            pbLowerStatStage(:ATTACK,1)
            pbRaiseStatStage(:DEFENSE,1)
          end
          if opposes?
            @battle.pbCommonAnimation("StanceProtectOpp",self)
          else
            @battle.pbCommonAnimation("StanceProtect",self)
          end
          pbChangeForm(0,_INTL("{1} changed to Shield Forme!",pbThis))
        end
      end
      # Calculate the move's type during this usage
      move.calcTypes = move.pbCalcTypes(self)
      # Start effect of Mold Breaker
      @battle.moldBreaker = hasMoldBreaker?
      # Remember that user chose a two-turn move
      if move.pbIsChargingTurn?(self)
        # Beginning the use of a two-turn attack
        @effects[PBEffects::TwoTurnAttack] = move.id
        @currentMove = move.id
      else
        @effects[PBEffects::TwoTurnAttack] = nil   # Cancel use of two-turn attack
      end
      # Add to counters for moves which increase them when used in succession
      move.pbChangeUsageCounters(self,specialUsage)
      # Charge up Metronome item
      if hasActiveItem?(:METRONOME) && !move.callsAnotherMove?
        if @lastMoveUsed && @lastMoveUsed==move.id && !@lastMoveFailed
          @effects[PBEffects::Metronome] += 1
        else
          @effects[PBEffects::Metronome] = 0
        end
      end
      # Record move as having been used
      @lastMoveUsed     = move.id
      @lastMoveUsedType = move.calcTypes[0]   # For Conversion 2
      if !specialUsage
        @lastRegularMoveUsed   = move.id   # For Disable, Encore, Instruct, Mimic, Mirror Move, Sketch, Spite
        @lastRegularMoveTarget = choice[3]   # For Instruct (remembering original target is fine)
        @movesUsed.push(move.id) if !@movesUsed.include?(move.id)   # For Last Resort
      end
      @battle.lastMoveUsed = move.id   # For Copycat
      @battle.lastMoveUser = @index   # For "self KO" battle clause to avoid draws
      @battle.successStates[@index].useState = 1   # Battle Arena - assume failure
      # Find the default user (self or Snatcher) and target(s)
      user = pbFindUser(choice,move)
      user = pbChangeUser(choice,move,user)
      targets = pbFindTargets(choice,move,user)
      targets = pbChangeTargets(move,user,targets)
      # Pressure
      if !specialUsage
        targets.each do |b|
          next unless b.opposes?(user)
          if b.hasActiveAbility?(:PRESSURE) && ![20,48].include?($fefieldeffect)
            user.pbReducePP(move)
            user.pbReducePP(move) if [5,6,32,38,45].include?($fefieldeffect)
          end
          if b.hasActiveAbility?([:UNNERVE,:ARENATRAP]) && $fefieldeffect == 5
            user.pbReducePP(move)
          end
        end
        if move.pbTarget(user).affects_foe_side # For moves that don't have a "targets" array
          @battle.eachOtherSideBattler(user) do |b|
            if b.hasActiveAbility?(:PRESSURE) && ![20,48].include?($fefieldeffect)
              user.pbReducePP(move)
              user.pbReducePP(move) if [5,6,32,38,45].include?($fefieldeffect)
            end
            if b.hasActiveAbility?([:UNNERVE,:ARENATRAP]) && $fefieldeffect == 5
              user.pbReducePP(move)
            end
          end
        end
      end
      # Dazzling/Queenly Majesty make the move fail here
      @battle.pbPriority(true).each do |b|
        next if !b || !b.abilityActive?
        #if BattleHandlers.triggerMoveBlockingAbility(b.ability,b,user,targets,move,@battle)
        if (b.hasActiveAbility?(:DAZZLING) && $fefieldeffect != 40 || b.hasActiveAbility?(:QUEENLYMAJESTY)) && 
           @battle.choices[user.index][4]>0 &&
           b.opposes?(user)
          oppTarget = false
          for t in targets
            next if !t.opposes?(user)
            oppTarget = true
          end
          if oppTarget
            @battle.pbShowAbilitySplash(b)
            @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4}!",b.pbThis,b.abilityName,user.pbThis(true),move.name))
            @battle.pbHideAbilitySplash(b)
            user.lastMoveFailed = true
            pbCancelMoves
            pbEndTurn(choice)
            return
          end
        end
      end
      # "X used Y!" message
      # Can be different for Bide, Fling, Focus Punch and Future Sight
      # NOTE: This intentionally passes self rather than user. The user is always
      #       self except if Snatched, but this message should state the original
      #       user (self) even if the move is Snatched.
      move.pbDisplayUseMessage(self)
      # Snatch's message (user is the new user, self is the original user)
      if move.snatched
        @lastMoveFailed = true   # Intentionally applies to self, not user
        @battle.pbDisplay(_INTL("{1} snatched {2}'s move!",user.pbThis,pbThis(true)))
      end
      # "But it failed!" checks
      if move.pbMoveFailed?(user,targets)
        PBDebug.log(sprintf("[Move failed] In function code %s's def pbMoveFailed?",move.function))
        user.lastMoveFailed = true
        pbCancelMoves
        user.checkFieldTransformations(move)
        pbEndTurn(choice)
        return
      end
      if move.failsDueToField?(user,true)
        user.effects[PBEffects::TwoTurnAttack] = nil
        user.lastMoveFailed = true
        pbCancelMoves
        pbEndTurn(choice)
        return
      end
      # Field Move Change
      if !move.zMove? # Z-Moves always work
        case $fefieldeffect
        when 4 # Dark Crystal Cavern
          if move.id == :DIVE
            @battle.pbDisplay(_INTL("But {1}'s only option is to dig!",user.pbThis(true)))
            user.pbUseMoveSimple(:DIG,choice[3])
            return
          end
        when 7 # Volcanic Field
          if move.id == :HIGHJUMPKICK
            @battle.pbDisplay(_INTL("But the ceiling was too low!"))
            user.pbUseMoveSimple(:JUMPKICK,choice[3])
            return
          elsif move.id == :DIVE
            @battle.pbDisplay(_INTL("But {1}'s only option is to dig!",user.pbThis(true)))
            user.pbUseMoveSimple(:DIG,choice[3])
            return
          end
        when 8 # Swamp Field
          if move.id == :SURF
            @battle.pbDisplay(_INTL("But the murk infected the attack!"))
            user.pbUseMoveSimple(:MUDDYWATER,choice[3])
            return
          end
        when 10 # Corrosive Field
          if move.id == :SURF
            @battle.pbDisplay(_INTL("But the corrosion tainted the attack!"))
            user.pbUseMoveSimple(:MUDDYWATER,choice[3])
            return
          elsif move.id == :SPIKES
            @battle.pbDisplay(_INTL("But they were covered in poison!"))
            user.pbUseMoveSimple(:TOXICSPIKES,choice[3])
            return
          end
        when 12 # Desert Field
          if [:MUDSLAP,:MUDSPORT].include?(move.id)
            @battle.pbDisplay(_INTL("But there was not enough moisture!"))
            user.pbUseMoveSimple(:SANDATTACK)
            return
          elsif [:MUDSHOT,:MUDBOMB].include?(move.id)
            @battle.pbDisplay(_INTL("But there was not enough moisture!"))
            user.pbUseMoveSimple(:SCORCHINGSANDS,choice[3])
            return
          end
        when 13 # Icy Cave
          if move.id == :HIGHJUMPKICK
            @battle.pbDisplay(_INTL("But the ceiling was too low!"))
            user.pbUseMoveSimple(:JUMPKICK,choice[3])
            return
          elsif move.id == :DIVE
            @battle.pbDisplay(_INTL("But {1}'s only option is to dig!",user.pbThis(true)))
            user.pbUseMoveSimple(:DIG,choice[3])
            return
          end
        when 14 # Rocky Field
          if move.id == :DIVE
            @battle.pbDisplay(_INTL("But {1}'s only option is to dig!",user.pbThis(true)))
            user.pbUseMoveSimple(:DIG,choice[3])
            return
          end
        when 16 # Volcanic Top Field
          if move.id == :FIRESPIN
            @battle.pbDisplay(_INTL("But the lava combined with the attack!"))
            user.pbUseMoveSimple(:MAGMASTORM,choice[3])
            return
          end
        when 18 # Short-Circuit Field
          if move.id == :IMPRISON
            @battle.pbDisplay(_INTL("But the attack caught up stray electricity!"))
            user.pbUseMoveSimple(:THUNDERCAGE)
            return
          end
        when 21 # Water Surface
          if move.id == :DIG
            @battle.pbDisplay(_INTL("But {1}'s only option is to dive!",user.pbThis(true)))
            user.pbUseMoveSimple(:DIVE,choice[3])
            return
          elsif [:EARTHQUAKE,:MAGNITUDE].include?(move.id)
            @battle.pbDisplay(_INTL("The seismic disruption caused a tsunami!"))
            user.pbUseMoveSimple(:TSUNAMI,choice[3])
            return
          end
        when 22 # Underwater
          if move.id == :MISTBALL
            @battle.pbDisplay(_INTL("But the water engulfed the attack!"))
            user.pbUseMoveSimple(:WATERPULSE,choice[3])
            return
          end
        when 23 # Cave
          if move.id == :HIGHJUMPKICK
            @battle.pbDisplay(_INTL("But the ceiling was too low!"))
            user.pbUseMoveSimple(:JUMPKICK,choice[3])
            return
          elsif move.id == :DIVE
            @battle.pbDisplay(_INTL("But {1}'s only option is to dig!",user.pbThis(true)))
            user.pbUseMoveSimple(:DIG,choice[3])
            return
          end
        when 25 # Crystal Cavern
          if move.id == :DIVE
            @battle.pbDisplay(_INTL("But {1}'s only option is to dig!",user.pbThis(true)))
            user.pbUseMoveSimple(:DIG,choice[3])
            return
          end
        when 26 # Murkwater Surface
          if move.id == :DIG
            @battle.pbDisplay(_INTL("But {1}'s only option is to dive!",user.pbThis(true)))
            user.pbUseMoveSimple(:DIVE,choice[3])
            return
          elsif move.id == :SLUDGE
            @battle.pbDisplay(_INTL("But the water created a wave!"))
            user.pbUseMoveSimple(:SLUDGEWAVE)
            return
          end
        when 27 # Mountain
          if move.id == :JUMPKICK
            @battle.pbDisplay(_INTL("But {1} gained height from a ledge!",user.pbThis(true)))
            user.pbUseMoveSimple(:HIGHJUMPKICK,choice[3])
            return
          end
        when 28 # Snowy Mountain
          if move.id == :JUMPKICK
            @battle.pbDisplay(_INTL("But {1} gained height from a ledge!",user.pbThis(true)))
            user.pbUseMoveSimple(:HIGHJUMPKICK,choice[3])
            return
          elsif move.id == :ROCKSLIDE
            @battle.pbDisplay(_INTL("{1} started an avalanche instead!",user.pbThis(true)))
            user.pbUseMoveSimple(:AVALANCHE)
            return
          end
        when 32 # Dragon's Den
          if move.id == :FLAMEWHEEL
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:SACREDFIRE,choice[3])
            return
          elsif move.id == :FIREPLEDGE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:BLASTBURN,choice[3])
            return
          elsif move.id == :WATERPLEDGE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:HYDROCANNON,choice[3])
            return
          elsif move.id == :GRASSPLEDGE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:FRENZYPLANT,choice[3])
            return
          elsif move.id == :MIRRORSHOT
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:DOOMDESIRE,choice[3])
            return
          elsif move.id == :PSYCHIC
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:PSYCHOBOOST,choice[3])
            return
          elsif move.isHiddenPower?
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:JUDGMENT,choice[3])
            return
          elsif @id == :OUTRAGE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:ROAROFTIME)
            return
          elsif @id == :DUALCHOP
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:SPACIALREND,choice[3])
            return
          elsif @id == :FIRESPIN
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:MAGMASTORM,choice[3])
            return
          elsif @id == :VISEGRIP
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:CRUSHGRIP,choice[3])
            return
          elsif @id == :ENERGYBALL
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:SEEDFLARE,choice[3])
            return
          elsif @id == :PHANTOMFORCE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:SHADOWFORCE,choice[3])
            return
          elsif @id == :KARATECHOP
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:SACREDSWORD,choice[3])
            return
          elsif @id == :PSYSHOCK
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:PSYSTRIKE,choice[3])
            return
          elsif @id == :INCINERATE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:SEARINGSHOT)
            return
          elsif @id == :HYPERBEAM
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:TECHNOBLAST,choice[3])
            return
          elsif @id == :ROUND
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:RELICSONG,choice[3])
            return
          elsif @id == :AURASPHERE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:SECRETSWORD,choice[3])
            return
          elsif @id == :ICYWIND
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:GLACIATE,choice[3])
            return
          elsif @id == :WILDCHARGE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:BOLTSTRIKE,choice[3])
            return
          elsif @id == :FLAMETHROWER
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:BLUEFLARE,choice[3])
            return
          elsif @id == :ICICLECRASH
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:FREEZESHOCK,choice[3])
            return
          elsif @id == :FREEZEDRY
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:ICEBURN,choice[3])
            return
          elsif @id == :FLAMECHARGE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:VCREATE,choice[3])
            return
          elsif @id == :BURNUP
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:FUSIONFLARE,choice[3])
            return
          elsif @id == :ELECTROBALL
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:FUSIONBOLT,choice[3])
            return
          elsif @id == :POWERGEM
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:DIAMONDSTORM)
            return
          elsif @id == :SCALD
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:STEAMERUPTION)
            return
          elsif @id == :EXTRASENSORY
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:HYPERSPACEHOLE,choice[3])
            return
          elsif @id == :GUST
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:AEROBLAST,choice[3])
            return
          elsif @id == :AIRSLASH
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:OBLIVIONWING,choice[3])
            return
          elsif @id == :MAGNITUDE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:LANDSWRATH)
            return
          elsif @id == :DAZZLINGGLEAM
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:LIGHTOFRUIN)
            return
          elsif @id == :WATERPULSE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:ORIGINPULSE)
            return
          elsif @id == :BULLDOZE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:PRECIPICEBLADES)
            return
          elsif @id == :BOUNCE && user.effects[PBEffects::TwoTurnAttack] == 0 # Not mid-use
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:DRAGONASCENT,choice[3])
            return
          elsif @id == :DRACOMETEOR
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:COREENFORCER)
            return
          elsif @id == :FAIRYWIND
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:FLEURCANNON,choice[3])
            return
          elsif @id == :PSYBEAM
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:PRISMATICLASER,choice[3])
            return
          elsif @id == :ASTONISH
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:SPECTRALTHIEF,choice[3])
            return
          elsif @id == :METEORMASH
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:SUNSTEELSTRIKE,choice[3])
            return
          elsif @id == :SHADOWBALL
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:MOONGEISTBEAM,choice[3])
            return
          elsif @id == :LAVAPLUME
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:MINDBLOWN,choice[3])
            return
          elsif @id == :STOREDPOWER
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:PHOTONGEYSER,choice[3])
            return
          elsif @id == :IRONHEAD
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:DOUBLEIRONBASH,choice[3])
            return
          elsif @id == :DRAGONPULSE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:DYNAMAXCANNON,choice[3])
            return
          elsif @id == :SMARTSTRIKE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:BEHEMOTHBLADE,choice[3])
            return
          elsif @id == :HEAVYSLAM
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:BEHEMOTHBASH,choice[3])
            return
          elsif @id == :DRAGONBREATH
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:ETERNABEAM,choice[3])
            return
          elsif @id == :LASHOUT
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:WICKEDBLOW,choice[3])
            return
          elsif @id == :LIQUIDATION
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:SURGINGSTRIKES,choice[3])
            return
          elsif @id == :ELECTROWEB
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:THUNDERCAGE)
            return
          elsif @id == :DRAGONRAGE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:DRAGONENERGY)
            return
          elsif @id == :CONFUSION
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:FREEZINGGLARE,choice[3])
            return
          elsif @id == :SNARL
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:FIERYWRATH)
            return
          elsif @id == :JUMPKICK
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:THUNDEROUSKICK,choice[3])
            return
          elsif @id == :ICICLESPEAR
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:GLACIALLANCE)
            return
          elsif @id == :OMINOUSWIND
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:ASTRALBARRAGE)
            return
          elsif @id == :DRILLRUN
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:THOUSANDARROWS)
            return
          elsif @id == :EARTHQUAKE
            @battle.pbDisplay(_INTL("The attack was upgraded to its beastly counterpart!"))
            user.pbUseMoveSimple(:THOUSANDWAVES)
            return
          end
        when 37 # Psychic Terrain
          if @id == :HEADBUTT
            @battle.pbDisplay(_INTL("But the attack was infused with zen energy!"))
            user.pbUseMoveSimple(:ZENHEADBUTT,choice[3])
            return
          end
        when 40 # Haunted Field
          if @id == :GUST
            @battle.pbDisplay(_INTL("But the attack was filled with ominosity!"))
            user.pbUseMoveSimple(:OMINOUSWIND,choice[3])
            return
          end
        when 41 # Corrupted Cave
          if move.id == :HIGHJUMPKICK
            @battle.pbDisplay(_INTL("But the ceiling was too low!"))
            user.pbUseMoveSimple(:JUMPKICK,choice[3])
            return
          elsif move.id == :DIVE
            @battle.pbDisplay(_INTL("But {1}'s only option is to dig!",user.pbThis(true)))
            user.pbUseMoveSimple(:DIG,choice[3])
            return
          elsif [:SURF,:MUDDYWATER,:TSUNAMI].include?(move.id)
            @battle.pbDisplay(_INTL("The chemicals infused the attack!"))
            user.pbUseMoveSimple(:SLUDGEWAVE,choice[3])
            return
          end
        when 44 # Indoors
          if move.id == :HIGHJUMPKICK
            @battle.pbDisplay(_INTL("But the ceiling was too low!"))
            user.pbUseMoveSimple(:JUMPKICK,choice[3])
            return
          end
        end
      end
      # Perform set-up actions and display messages
      # Messages include Magnitude's number and Pledge moves' "it's a combo!"
      Achievements.incrementProgress("MOVES_USED",1) if user.pbOwnedByPlayer? 
      move.pbOnStartUse(user,targets)
      # Self-thawing due to the move
      if user.status == :FROZEN && move.thawsUser?
        user.pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1} melted the ice!",user.pbThis))
      end
      # Powder
      if user.effects[PBEffects::Powder] && move.calcTypes.include?(:FIRE)
        @battle.pbCommonAnimation("Powder",user)
        @battle.pbDisplay(_INTL("When the flame touched the powder on the Pokémon, it exploded!"))
        user.lastMoveFailed = true
        if ![:Rain, :HeavyRain].include?(@battle.pbWeather) && user.takesIndirectDamage?
          oldHP = user.hp
          user.pbReduceHP((user.totalhp/4.0).round,false)
          user.pbFaint if user.fainted?
          @battle.pbGainExp   # In case user is KO'd by this
          user.pbItemHPHealCheck
          if user.pbAbilitiesOnDamageTaken(oldHP)
            user.pbEffectsOnSwitchIn(true)
          end
        end
        pbCancelMoves
        pbEndTurn(choice)
        return
      end
      # Primordial Sea, Desolate Land
      if move.damagingMove?
        case @battle.pbWeather
        when :HeavyRain
          if move.calcTypes.include?(:FIRE)
            @battle.pbDisplay(_INTL("The Fire-type attack fizzled out in the heavy rain!"))
            user.lastMoveFailed = true
            pbCancelMoves
            pbEndTurn(choice)
            return
          end
        when :HarshSun
          if move.calcTypes.include?(:WATER)
            @battle.pbDisplay(_INTL("The Water-type attack evaporated in the harsh sunlight!"))
            user.lastMoveFailed = true
            pbCancelMoves
            pbEndTurn(choice)
            return
          end
        end
      end
      # Protean / Libero
      if (user.hasActiveAbility?(:PROTEAN) && $fefieldeffect != 24 || user.hasActiveAbility?(:LIBERO) && 
         !($fefieldeffect == 8 && user.grounded?) && $fefieldeffect != 22) && !move.callsAnotherMove? && 
         !move.snatched
        if user.pbHasOtherType?(move.calcTypes[0]) && !GameData::Type.get(move.calcTypes[0]).pseudo_type
          @battle.pbShowAbilitySplash(user)
          user.pbChangeTypes(move.calcTypes)
          typeName = GameData::Type.get(move.calcTypes[0]).name
          @battle.pbDisplay(_INTL("{1}'s {2} transformed it into the {3} type!",user.pbThis,user.abilityName,typeName))
          @battle.pbHideAbilitySplash(user)
          # NOTE: The GF games say that if Curse is used by a non-Ghost-type
          #       Pokémon which becomes Ghost-type because of Protean / Libero,
          #       it should target and curse itself. I think this is silly, so
          #       I'm making it choose a random opponent to curse instead.
          if move.function == "10D" && targets.length == 0   # Curse
            choice[3] = -1
            targets = pbFindTargets(choice,move,user)
          end
        end
      end
      # Color Change + Rainbow Field/Crystal Cavern
      if user.hasActiveAbility?(:COLORCHANGE) && [9,25].include?($fefieldeffect) && 
         !move.callsAnotherMove? && !move.snatched
        if user.pbHasOtherType?(move.calcTypes[0]) && !GameData::Type.get(move.calcTypes[0]).pseudo_type
          user.pbChangeTypes(move.calcTypes[0],false,true)
          typeName = GameData::Type.get(move.calcTypes[0]).name
          @battle.pbDisplay(_INTL("{1}'s {2} transformed it into the {3} type!",user.pbThis,user.abilityName,typeName))
          # NOTE: The GF games say that if Curse is used by a non-Ghost-type
          #       Pokémon which becomes Ghost-type because of Protean / Libero,
          #       it should target and curse itself. I think this is silly, so
          #       I'm making it choose a random opponent to curse instead.
          if move.function == "10D" && targets.length == 0   # Curse
            choice[3] = -1
            targets = pbFindTargets(choice,move,user)
          end
        end
      end
      # Fairy Tale Field - Warlock
      if $fefieldeffect == 31 && [:DARK,:PSYCHIC,:GHOST,:POISON].include?(move.calcTypes[0]) && 
         move.specialMove? && user.effects[PBEffects::FairyTaleRoles].include?(10) &&
         !move.callsAnotherMove? && !move.snatched
        if user.pbHasOtherType?(move.calcTypes[0])
          user.pbChangeTypes(move.calcTypes[0])
          typeName = GameData::Type.get(move.calcTypes[0]).name
          @battle.pbDisplay(_INTL("{1}'s Warlock role transformed it into the {2} type!",user.pbThis,typeName))
        end
      end
      for b in targets
        # Protean + Rainbow Field
        if b.hasActiveAbility?(:PROTEAN) && $fefieldeffect == 9 && move.damagingMove?
          newType = @battle.generateRandomType
          if b.pbHasOtherType?(newType) && !GameData::Type.get(newType).pseudo_type
            b.pbChangeTypes(newType)
            typeName = GameData::Type.get(newType).name
            @battle.pbDisplay(_INTL("{1}'s {2} transformed it into the {3} type!",b.pbThis,b.abilityName,typeName))
          end
        end
        # Fairy Tale Field - Druid
        if $fefieldeffect == 31 && b.effects[PBEffects::FairyTaleRoles].include?(3) &&
           !move.callsAnotherMove? && !move.snatched && move.damagingMove?
          minEff = move.pbCalcTypeModSingle(move.calcTypes,:BUG,user,b)
          minType = :BUG
          for t in [:FAIRY,:FLYING,:GRASS,:GROUND,:WATER]
            newEff = move.pbCalcTypeModSingle(move.calcTypes,t,user,b)
            if newEff < minEff
              minEff = newEff
              minType = t
            end
          end
          if b.pbHasOtherType?(minType) && !GameData::Type.get(minType).pseudo_type
            b.pbChangeTypes(minType)
            typeName = GameData::Type.get(minType).name
            @battle.pbDisplay(_INTL("{1}'s Druid role transformed it into the {2} type!",b.pbThis,typeName))
          end
        end
      end
      # Redirect Dragon Darts first hit if necessary
      if move.function == "17C" && @battle.pbSideSize(targets[0].index) > 1
        targets = pbChangeTargets(move,user,targets,0)
      end
      #---------------------------------------------------------------------------
      magicCoater  = -1
      magicBouncer = -1
      if targets.length == 0 && move.pbTarget(user).num_targets > 0 && !move.worksWithNoTargets?
        # def pbFindTargets should have found a target(s), but it didn't because
        # they were all fainted
        # All target types except: None, User, UserSide, FoeSide, BothSides
        @battle.pbDisplay(_INTL("But there was no target..."))
        user.lastMoveFailed = true
      else   # We have targets, or move doesn't use targets
        # Reset whole damage state, perform various success checks (not accuracy)
        user.initialHP = user.hp
        targets.each do |b|
          b.damageState.reset
          b.damageState.initialHP = b.hp
          if !pbSuccessCheckAgainstTarget(move,user,b)
            b.damageState.unaffected = true
          end
        end
        # Magic Coat/Magic Bounce checks (for moves which don't target Pokémon)
        if targets.length==0 && move.canMagicCoat?
          @battle.pbPriority(true).each do |b|
            next if b.fainted? || !b.opposes?(user)
            next if b.semiInvulnerable?
            if b.effects[PBEffects::MagicCoat]
              magicCoater = b.index
              b.effects[PBEffects::MagicCoat] = false
              break
            elsif b.hasActiveAbility?(:MAGICBOUNCE) && !@battle.moldBreaker && !b.effects[PBEffects::MagicBounce]
              magicBouncer = b.index
              b.effects[PBEffects::MagicBounce] = true
              break
            end
          end
        end
        # Get the number of hits
        numHits = move.pbNumHits(user,targets)
        # Process each hit in turn
        realNumHits = 0
        for i in 0...numHits
          break if magicCoater>=0 || magicBouncer>=0
          success = pbProcessMoveHit(move,user,targets,i,skipAccuracyCheck)
          if !success
            if i==0 && targets.length>0
              hasFailed = false
              targets.each do |t|
                next if t.damageState.protected
                hasFailed = t.damageState.unaffected
                break if !t.damageState.unaffected
              end
              user.lastMoveFailed = hasFailed
            end
            break
          end
          realNumHits += 1
          break if user.fainted?
          break if [:SLEEP, :FROZEN].include?(user.status)
          # NOTE: If a multi-hit move becomes disabled partway through doing those
          #       hits (e.g. by Cursed Body), the rest of the hits continue as
          #       normal.
          # Don't stop using the move if Dragon Darts could still hit something
          if move.function == "17C" && realNumHits < numHits
            endMove = true
            @battle.eachBattler do |b|
              next if b == self
              endMove = false
            end
            break if endMove
          else
            # All targets are fainted
            break if targets.all? { |t| t.fainted? }
          end
        end
        # Battle Arena only - attack is successful
        @battle.successStates[user.index].useState = 2
        if targets.length>0
          @battle.successStates[user.index].typeMod = 0
          targets.each do |b|
            next if b.damageState.unaffected
            @battle.successStates[user.index].typeMod += b.damageState.typeMod
          end
        end
        # Effectiveness message for multi-hit moves
        # NOTE: No move is both multi-hit and multi-target, and the messages below
        #       aren't quite right for such a hypothetical move.
        if numHits>1
          if move.damagingMove?
            targets.each do |b|
              next if b.damageState.unaffected || b.damageState.substitute
              move.pbEffectivenessMessage(user,b,targets.length)
            end
          end
          if realNumHits==1
            @battle.pbDisplay(_INTL("Hit 1 time!"))
          elsif realNumHits>1
            @battle.pbDisplay(_INTL("Hit {1} times!",realNumHits))
          end
        end
        # Magic Coat's bouncing back (move has targets)
        targets.each do |b|
          next if b.fainted?
          next if !b.damageState.magicCoat && !b.damageState.magicBounce
          @battle.pbShowAbilitySplash(b) if b.damageState.magicBounce
          @battle.pbDisplay(_INTL("{1} bounced the {2} back!",b.pbThis,move.name))
          if $fefieldeffect == 30
            b.pbRaiseStatStage(:EVASION,1,nil)
          elsif $fefieldeffect == 37
            b.pbRaiseStatStage(:SPECIAL_ATTACK,1,nil)
          end
          @battle.pbHideAbilitySplash(b) if b.damageState.magicBounce
          newChoice = choice.clone
          newChoice[3] = user.index
          newTargets = pbFindTargets(newChoice,move,b)
          newTargets = pbChangeTargets(move,b,newTargets)
          success = pbProcessMoveHit(move,b,newTargets,0,false)
          b.lastMoveFailed = true if !success
          targets.each { |otherB| otherB.pbFaint if otherB && otherB.fainted? }
          user.pbFaint if user.fainted?
        end
        # Magic Coat's bouncing back (move has no targets)
        if magicCoater>=0 || magicBouncer>=0
          mc = @battle.battlers[(magicCoater>=0) ? magicCoater : magicBouncer]
          if !mc.fainted?
            user.lastMoveFailed = true
            @battle.pbShowAbilitySplash(mc) if magicBouncer>=0
            @battle.pbDisplay(_INTL("{1} bounced the {2} back!",mc.pbThis,move.name))
            if $fefieldeffect == 5
              if $fecounter < 6 # White
                $fecounter+=6
                fieldColor = "Black"
              else # Black
                $fecounter-=6
                fieldColor = "White"
              end
              @battle.changeFieldBG
              @battle.pbDisplay(_INTL("The field changed to {1}'s turn!",fieldColor))
            elsif $fefieldeffect == 30
              b.pbRaiseStatStage(:EVASION,1,nil)
            elsif $fefieldeffect == 37
              b.pbRaiseStatStage(:SPECIAL_ATTACK,1,nil)
            end
            @battle.pbHideAbilitySplash(mc) if magicBouncer>=0
            success = pbProcessMoveHit(move,mc,[],0,false)
            mc.lastMoveFailed = true if !success
            targets.each { |b| b.pbFaint if b && b.fainted? }
            user.pbFaint if user.fainted?
          end
        end
        # Move-specific effects after all hits
        targets.each { |b| move.pbEffectAfterAllHits(user,b) }
        # Faint if 0 HP
        targets.each { |b| 
          if b && b.fainted?
            b.pbFaint
          end
        }
        user.pbFaint if user.fainted?
        # External/general effects after all hits. Eject Button, Shell Bell, etc.
        pbEffectsAfterMove(user,targets,move,realNumHits)
      end
      user.checkFieldTransformations(move)
      # End effect of Mold Breaker
      @battle.moldBreaker = false
      # Gain Exp
      @battle.pbGainExp
      # Battle Arena only - update skills
      @battle.eachBattler { |b| @battle.successStates[b.index].updateSkill }
      # Shadow Pokémon triggering Hyper Mode
      pbHyperMode if @battle.choices[@index][0]!=:None   # Not if self is replaced
      # End of move usage
      pbEndTurn(choice)
      # Instruct
      @battle.eachBattler do |b|
        next if !b.effects[PBEffects::Instruct] || !b.lastMoveUsed
        b.effects[PBEffects::Instruct] = false
        idxMove = -1
        b.eachMoveWithIndex { |m,i| idxMove = i if m.id==b.lastMoveUsed }
        next if idxMove<0
        oldLastRoundMoved = b.lastRoundMoved
        @battle.pbDisplay(_INTL("{1} used the move instructed by {2}!",b.pbThis,user.pbThis(true)))
        PBDebug.logonerr{
          b.effects[PBEffects::Instructed] = true
          b.pbUseMoveSimple(b.lastMoveUsed,b.lastRegularMoveTarget,idxMove,false)
          b.effects[PBEffects::Instructed] = false
        }
        b.lastRoundMoved = oldLastRoundMoved
        @battle.pbJudge
        return if @battle.decision>0
      end
      # Dancer
      if !@effects[PBEffects::Dancer] && !user.lastMoveFailed && realNumHits>0 &&
         !move.snatched && magicCoater<0 && move.danceMove?
        dancers = []
        @battle.pbPriority(true).each do |b|
          dancers.push(b) if b.index!=user.index && (b.hasActiveAbility?(:DANCER) &&
                             $fefieldeffect != 12 && !([8,26].include?($fefieldeffect) &&
                             b.grounded?) || b.hasActiveAbility?([:QUICKFEET,:DEATHWALTZ,:PERFORMER]) && 
                             $fefieldeffect == 6)
        end
        while dancers.length>0
          nextUser = dancers.pop
          oldLastRoundMoved = nextUser.lastRoundMoved
          # NOTE: Petal Dance being used because of Dancer shouldn't lock the
          #       Dancer into using that move, and shouldn't contribute to its
          #       turn counter if it's already locked into Petal Dance.
          oldOutrage = nextUser.effects[PBEffects::Outrage]
          nextUser.effects[PBEffects::Outrage] += 1 if nextUser.effects[PBEffects::Outrage]>0
          oldCurrentMove = nextUser.currentMove
          preTarget = choice[3]
          preTarget = user.index if nextUser.opposes?(user) || !nextUser.opposes?(preTarget)
          @battle.pbShowAbilitySplash(nextUser,true)
          @battle.pbHideAbilitySplash(nextUser)
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} kept the dance going with {2}!",
               nextUser.pbThis,nextUser.abilityName))
          end
          PBDebug.logonerr{
            nextUser.effects[PBEffects::Dancer] = true
            nextUser.pbUseMoveSimple(move.id,preTarget)
            nextUser.effects[PBEffects::Dancer] = false
          }
          nextUser.lastRoundMoved = oldLastRoundMoved
          nextUser.effects[PBEffects::Outrage] = oldOutrage
          nextUser.currentMove = oldCurrentMove
          @battle.pbJudge
          return if @battle.decision>0
        end
      end
      @battle.eachBattler do |b|
        next if !b.hasActiveItem?(:ROOMSERVICE)
        next if battle.field.effects[PBEffects::TrickRoom] == 0
        next if !b.pbCanLowerStatStage?(:SPEED,b)
        b.pbLowerStatStageByCause(:SPEED,1,b,b.itemName)
        b.pbConsumeItem
      end
    end
  
    #=============================================================================
    # Attack a single target
    #=============================================================================
    def pbProcessMoveHit(move,user,targets,hitNum,skipAccuracyCheck)
      return false if user.fainted?
      # For two-turn attacks being used in a single turn
      move.pbInitialEffect(user,targets,hitNum)
      numTargets = 0   # Number of targets that are affected by this hit
      # Count a hit for Parental Bond (if it applies)
      user.effects[PBEffects::ParentalBond] -= 1 if user.effects[PBEffects::ParentalBond]>0
      user.effects[PBEffects::HitsTwice]    -= 1 if user.effects[PBEffects::HitsTwice]>0
      # Redirect Dragon Darts other hits
      if move.function=="17C" && @battle.pbSideSize(targets[0].index)>1 && hitNum>0
        targets = pbChangeTargets(move,user,targets,1)
      end
      targets.each { |b| b.damageState.resetPerHit }
      # Accuracy check (accuracy/evasion calc)
      if hitNum==0 || move.successCheckPerHit?
        targets.each do |b|
          next if b.damageState.unaffected
          if pbSuccessCheckPerHit(move,user,b,skipAccuracyCheck)
            numTargets += 1
          else
            b.damageState.missed     = true
            b.damageState.unaffected = true
          end
        end
        # If failed against all targets
        if targets.length>0 && numTargets==0 && !move.worksWithNoTargets?
          targets.each do |b|
            next if !b.damageState.missed || b.damageState.magicCoat
            pbMissMessage(move,user,b)
            case $fefieldeffect
            when 4 # Dark Crystal Cavern
              if move.crystalRefractMove? && @battle.pbRandom(2) == 0
                @battle.pbDisplay(_INTL("The crystals refracted the attack!"))
                user.effects[PBEffects::NeverMiss]=true
                user.pbUseMoveSimple(move.id,-1,b.index)
              end
            when 13 # Icy Cave
              if move.beamMove? && @battle.pbRandom(2) == 0
                @battle.pbDisplay(_INTL("The attack was reflected off the ice!"))
                user.effects[PBEffects::NeverMiss]=true
                user.pbUseMoveSimple(move.id)
              end
            when 25 # Crystal Cavern
              if move.crystalRefractMove?
                @battle.pbDisplay(_INTL("The crystals refracted the attack!"))
                user.effects[PBEffects::NeverMiss]=true
                user.pbUseMoveSimple(move.id,-1,b.index)
              end
            when 30 # Mirror Arena
              if move.beamMove?
                @battle.pbDisplay(_INTL("The attack was reflected by the mirror!"))
                user.effects[PBEffects::NeverMiss]=true
                user.pbUseMoveSimple(move.id)
              end
            end
          end
          move.pbCrashDamage(user)
          if $fefieldeffect == 4 && move.physicalMove?
            @battle.pbDisplay(_INTL("{1} shattered a crystal instead!",user.pbThis))
            r=rand(200)/2.0
            for b in @battle.battlers
              next if b.fainted?
              if r>=99
                if b.pbOwnSide.effects[PBEffects::AuroraVeil]==0
                  b.pbOwnSide.effects[PBEffects::AuroraVeil]=5
                  @battle.pbAnimation(:AURORAVEIL,b,nil)
                  @battle.pbDisplay(_INTL("The crystal's energy shrouded {1}'s team in an Aurora Veil!",b.pbThis(true)))
                end
              elsif r>=98
                if b.pbOwnSide.effects[PBEffects::LuckyChant]==0
                  b.pbOwnSide.effects[PBEffects::LuckyChant]=5
                  @battle.pbAnimation(:LUCKYCHANT,b,nil)
                  @battle.pbDisplay(_INTL("The crystal's energy shrouded {1}'s team with Lucky Chant!",b.pbThis(true)))
                end
              elsif r>=97
                b.pbChangeTypes([@battle.generateRandomType,@battle.generateRandomType])
                @battle.pbAnimation(:CAMOUFLAGE,b,nil)
                if b.type1 == b.type2
                  @battle.pbDisplay(_INTL("The crystal infused {1} with energy, making it the {2} type!",b.pbThis(true),GameData::Type.get(b.type1).name))
                else
                  @battle.pbDisplay(_INTL("The crystal infused {1} with energy, making it the {2} and {3} types!",b.pbThis(true),
                                    GameData::Type.get(b.type1).name,GameData::Type.get(b.type2).name))
                end
              elsif r>=96
                if b == @battle.battlers[0]
                  @battle.pbAnimation(:PERISHSONG,user,nil)
                  @battle.pbDisplay(_INTL("The crystal emitted a Perish Song!"))
                  @battle.pbDisplay(_INTL("All Pokémon that hear the song will faint in three turns!"))
                end
                if b.effects[PBEffects::PerishSong]==0
                  if !(b.hasActiveAbility?(:SOUNDPROOF))
                    b.effects[PBEffects::PerishSong]=4
                    b.effects[PBEffects::PerishSongUser]=user.index
                  end
                end
              elsif r>=95
                if b.effects[PBEffects::MagnetRise]==0
                  @battle.pbAnimation(:MAGNETRISE,b,nil)
                  @battle.pbDisplay(_INTL("The crystal infused {1} with energy, making it levitate!",b.pbThis(true)))
                  b.effects[PBEffects::MagnetRise]=5
                end
              elsif r>=90 # Effect Removed
              elsif r>=85
                @battle.pbDisplay(_INTL("The crystal emitted light energy!")) if b == @battle.battlers[0]
                @battle.pbCommonAnimation("Sky Attack charging",b,nil)
                b.pbSetPP(move,move.total_pp)
                @battle.pbDisplay(_INTL("The PP of {1}'s {2} was restored!",b.pbThis(true),move.name))
              elsif r>=80
                @battle.pbDisplay(_INTL("The crystal emitted dark energy!")) if b == @battle.battlers[0]
                @battle.pbAnimation(:DARKPULSE,b,b)
                b.pbSetPP(move,0)
                @battle.pbDisplay(_INTL("The PP of {1}'s {2} was set to 0!",b.pbThis(true),move.name))
              elsif r>=75
                @battle.pbDisplay(_INTL("The crystal emitted dark energy!")) if b == @battle.battlers[0]
                @battle.pbAnimation(:DARKPULSE,b,b)
                for i in [:ATTACK,:DEFENSE,:SPEED,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:ACCURACY,:EVASION]
                  b.stages[i]*=-1
                end
                @battle.pbDisplay(_INTL("{1}'s stat changes were inverted!",b.pbThis))
              elsif r>=65
                @battle.pbAnimation(:DARKPULSE,b,b)
                b.pbCheckAndInflictRandomStatus(nil,true)
              elsif r>=50
                @battle.pbDisplay(_INTL("The crystal emitted dark energy!")) if b == @battle.battlers[0]
                @battle.pbAnimation(:DARKPULSE,b,b)
                if r>=64
                  increment=6
                elsif r>=62
                  increment=3
                elsif r>=59
                  increment=2
                else
                  increment=1
                end
                b.pbLowerStatStage([:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED],increment,nil,true)
              elsif r>=35
                @battle.pbDisplay(_INTL("The crystal emitted light energy!")) if b == @battle.battlers[0]
                @battle.pbCommonAnimation("Sky Attack charging",b,nil)
                if r>=49
                  increment=6
                elsif r>=47
                  increment=3
                elsif r>=44
                  increment=2
                else
                  increment=1
                end
                b.pbRaiseStatStage([:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED],increment,nil,true)
              elsif r>=25
                @battle.pbDisplay(_INTL("The crystal emitted dark energy!")) if b == @battle.battlers[0]
                @battle.pbAnimation(:DARKPULSE,b,b)
                if r>=34
                  amt=b.totalhp
                elsif r>=32.5
                  amt=b.totalhp/2
                elsif r>=30
                  amt=b.totalhp/4
                else
                  amt=b.totalhp/8
                end
                b.pbReduceHP(amt,true)
              elsif r>=15
                @battle.pbDisplay(_INTL("The crystal emitted light energy!")) if b == @battle.battlers[0]
                @battle.pbCommonAnimation("Sky Attack charging",b,nil)
                if r>=24
                  amt=b.totalhp
                elsif r>=22.5
                  amt=b.totalhp/2
                elsif r>=20
                  amt=b.totalhp/4
                else
                  amt=b.totalhp/8
                end
                b.pbRecoverHP(amt,true)
                if b.status>0
                  b.pbCureStatus(false)
                  @battle.pbDisplay(_INTL("{1}'s status condition was cured!",b.pbThis))
                end
              end
            end
          elsif $fefieldeffect == 14 && move.pbContactMove?(user) && !user.hasActiveAbility?(:ROCKHEAD)
            if user.pbReduceHP(user.totalhp/8) > 0
              @battle.pbDisplay(_INTL("{1} hit a rock instead!",user.pbThis))
            end
          elsif $fefieldeffect == 25 && move.pbContactMove?(user)
            @battle.pbDisplay(_INTL("{1} shattered a crystal instead!",user.pbThis))
            @battle.pbAnimation(:CAMOUFLAGE,user,nil)
            user.effects[PBEffects::Type3]=@battle.crystalType
            @battle.pbDisplay(_INTL("{1} gained additional {2} typing!",user.pbThis,GameData::Type.get(@battle.crystalType).name))
            case $fecounter
            when 0
              if user.pbCanBurn?(nil,false)
                user.pbBurn
              end
            when 1
              if user.effects[PBEffects::Trapping] == 0
                user.effects[PBEffects::Trapping] = 4
                user.effects[PBEffects::TrappingMove] = :WHIRLPOOL
                user.effects[PBEffects::TrappingUser] = user.index
                @battle.pbAnimation(:WHIRLPOOL,user,user)
                @battle.pbDisplay(_INTL("{1} became trapped in the vortex!",user.pbThis))
              end
            when 2
              if !user.effects[PBEffects::Ingrain]
                user.effects[PBEffects::Ingrain] = true
                @battle.pbAnimation(:INGRAIN,user,nil)
                @battle.pbDisplay(_INTL("{1} planted its roots!",user.pbThis))
              end
            when 3
              if user.effects[PBEffects::MagnetRise] == 0
                user.effects[PBEffects::MagnetRise] = 5
                @battle.pbAnimation(:MAGNETRISE,user,nil)
                @battle.pbDisplay(_INTL("{1} levitated with electromagnetism!",user.pbThis))
              end
            when 4
              if user.effects[PBEffects::HealBlock] == 0
                user.effects[PBEffects::HealBlock] = 5
                @battle.pbAnimation(:HEALBLOCK,user,nil)
                @battle.pbDisplay(_INTL("{1} was prevented from healing!",user.pbThis))
              end
            when 5
              if !user.effects[PBEffects::Curse]
                user.effects[PBEffects::Curse] = true
                @battle.pbAnimation(:CURSE,user,user)
                @battle.pbDisplay(_INTL("{1} had a curse laid on it!",user.pbThis))
              end
            when 6
              if user.effects[PBEffects::Telekinesis] == 0
                user.effects[PBEffects::Telekinesis] = 3
                @battle.pbAnimation(:TELEKINESIS,user,user)
                @battle.pbDisplay(_INTL("{1} was hurled into the air!",user.pbThis))
              end
            end
          elsif $fefieldeffect == 30 && move.pbContactMove?(user)
            if user.pbReduceHP(user.totalhp/4) > 0
              @battle.pbDisplay(_INTL("{1} shattered a mirror instead!",user.pbThis))
            end
          elsif $fefieldeffect == 44 && move.pbContactMove?(user)
            if !user.hasActiveAbility?([:ROCKHEAD,:IRONFIST,:LIMBER])
              if user.pbReduceHP(user.totalhp/8) > 0
                @battle.pbDisplay(_INTL("{1} hit a piece of furniture instead!",user.pbThis))
              end 
            end
          end
          user.pbItemHPHealCheck
          # Blunder Policy
          if user.hasActiveItem?(:BLUNDERPOLICY) && user.effects[PBEffects::BlunderPolicy] &&
             targets[0].effects[PBEffects::TwoTurnAttack] == 0 && move.function != "070" && hitNum == 0
            if user.pbCanRaiseStatStage?(:SPEED,user,self)
              if $fefieldeffect == 5
                pbRaiseStatStageByCause([:SPEED,:SPECIAL_ATTACK,:ACCURACY],2,user,itemName)
              else
                pbRaiseStatStageByCause(:SPEED,2,user,itemName)
              end
              user.pbConsumeItem
            end
          end
          pbCancelMoves
          return false
        end
      end
      # If we get here, this hit will happen and do something
      #---------------------------------------------------------------------------
      # Calculate damage to deal
      if move.pbDamagingMove?
        targets.each do |b|
          next if b.damageState.unaffected
          # Check whether Substitute/Disguise will absorb the damage
          move.pbCheckDamageAbsorption(user,b)
          # Calculate the damage against b
          # pbCalcDamage shows the "eat berry" animation for SE-weakening
          # berries, although the message about it comes after the additional
          # effect below
          move.pbCalcDamage(user,b,targets.length)   # Stored in damageState.calcDamage
          # Lessen damage dealt because of False Swipe/Endure/etc.
          move.pbReduceDamage(user,b)   # Stored in damageState.hpLost
        end
      end
      @battle.field.effects[PBEffects::StrikeValue] = 0 if $fefieldeffect == 6
      # Show move animation (for this hit)
      move.pbShowAnimation(move.id,user,targets,hitNum)
      # Type-boosting Gem consume animation/message
      if user.effects[PBEffects::GemConsumed] && hitNum == 0
        # NOTE: The consume animation and message for Gems are shown now, but the
        #       actual removal of the item happens in def pbEffectsAfterMove.
        @battle.pbCommonAnimation("UseItem",user)
        @battle.pbDisplay(_INTL("The {1} strengthened {2}'s power!",
           GameData::Item.get(user.effects[PBEffects::GemConsumed]).name,move.name))
      end
      # Messages about missed target(s) (relevant for multi-target moves only)
      targets.each do |b|
        next if !b.damageState.missed
        pbMissMessage(move,user,b)
        # Blunder Policy (also activates if only one target is missed)
        if user.hasActiveItem?(:BLUNDERPOLICY) && user.effects[PBEffects::BlunderPolicy] &&
          b.effects[PBEffects::TwoTurnAttack] == 0 && move.function != "070" && hitNum == 0
          if user.pbCanRaiseStatStage?(:SPEED,user,self)
            pbRaiseStatStageByCause(:SPEED,2,user,itemName)
            user.pbConsumeItem
          end
        end
      end
      # Deal the damage (to all allies first simultaneously, then all foes
      # simultaneously)
      if move.pbDamagingMove?
        # This just changes the HP amounts and does nothing else
        targets.each do |b|
          next if b.damageState.unaffected
          move.pbInflictHPDamage(b,user)
        end
        # Animate the hit flashing and HP bar changes
        move.pbAnimateHitAndHPLost(user,targets)
      end
      # Self-Destruct/Explosion's damaging and fainting of user
      move.pbSelfKO(user) if hitNum==0
      user.pbFaint if user.fainted?
      if move.pbDamagingMove?
        targets.each do |b|
          next if b.damageState.unaffected
          # NOTE: This method is also used for the OKHO special message.
          move.pbHitEffectivenessMessages(user,b,targets.length)
          # Record data about the hit for various effects' purposes
          move.pbRecordDamageLost(user,b)
        end
        # Close Combat/Superpower's stat-lowering, Flame Burst's splash damage,
        # and Incinerate's berry destruction
        targets.each do |b|
          next if b.damageState.unaffected
          move.pbEffectWhenDealingDamage(user,b)
        end
      end
      # Ability/item effects such as Static/Rocky Helmet, and Grudge, etc.
      targets.each do |b|
        next if b.damageState.unaffected
        pbEffectsOnMakingHit(move,user,b)
      end
      if move.pbDamagingMove?
        # Disguise/Endure/Sturdy/Focus Sash/Focus Band messages
        targets.each do |b|
          next if b.damageState.unaffected
          move.pbEndureKOMessage(b)
        end
        # HP-healing held items (checks all battlers rather than just targets
        # because Flame Burst's splash damage affects non-targets)
        @battle.pbPriority(true).each { |b| b.pbItemHPHealCheck }
        # Animate battlers fainting (checks all battlers rather than just targets
        # because Flame Burst's splash damage affects non-targets)
        @battle.pbPriority(true).each { |b| b.pbFaint if b && b.fainted? }
      end
      @battle.pbJudgeCheckpoint(user,move)
      # Main effect (recoil/drain, etc.)
      targets.each do |b|
        next if b.damageState.unaffected
        move.pbEffectAgainstTarget(user,b)
      end
      move.pbEffectGeneral(user)
      targets.each { |b| b.pbFaint if b && b.fainted? }
      user.pbFaint if user.fainted?
      # Additional effect
      if !user.hasActiveAbility?(:SHEERFORCE) && ($fefieldeffect != 29 || !user.pbHasType?(:DARK) &&
         !user.pbHasType?(:GHOST)) # Dark/Ghost mons don't receive additional effects on Holy Field
        targets.each do |b|
          next if b.damageState.calcDamage==0
          chance = move.pbAdditionalEffectChance(user,b)
          next if chance<=0
          if @battle.pbRandom(100)<chance
            if b.hasShieldDust? && !@battle.moldBreaker
              if $fefieldeffect == 19
                user.pbCheckAndInflictRandomStatus(b)
              end
            else
              move.pbAdditionalEffect(user,b)
              if $fefieldeffect == 40 && b.effects[PBEffects::HauntedScared] != user.index &&
                 !b.pbHasType?(:GHOST) && (move.calcTypes.include?(:GHOST) || move.calcTypes.include?(:DARK)) &&
                 b.opposes?(user) && !b.hasActiveItem?(:BRIGHTPOWDER)
                b.effects[PBEffects::HauntedScared] = user.index
                @battle.pbDisplay(_INTL("{1} became scared of {2}!",b.pbThis,user.pbThis(true)))
              end
            end
          end
        end
      end
      # Make the target flinch (because of an item/ability)
      targets.each do |b|
        next if b.fainted?
        next if b.damageState.calcDamage==0 || b.damageState.substitute
        chance = move.pbFlinchChance(user,b)
        next if chance<=0
        if @battle.pbRandom(100)<chance
          PBDebug.log("[Item/ability triggered] #{user.pbThis}'s King's Rock/Razor Fang or Stench")
          b.pbFlinch(user)
        end
      end
      # Message for and consuming of type-weakening berries
      # NOTE: The "consume held item" animation for type-weakening berries occurs
      #       during pbCalcDamage above (before the move's animation), but the
      #       message about it only shows here.
      targets.each do |b|
        next if b.damageState.unaffected
        next if !b.damageState.berryWeakened
        @battle.pbDisplay(_INTL("The {1} weakened the damage to {2}!",b.itemName,b.pbThis(true)))
        b.pbConsumeItem
      end
      targets.each { |b| b.pbFaint if b && b.fainted? }
      user.pbFaint if user.fainted?
      return true
    end
  end
  