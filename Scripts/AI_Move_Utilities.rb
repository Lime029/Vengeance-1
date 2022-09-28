class PokeBattle_AI
    #=============================================================================
    #
    #=============================================================================
    def pbTargetsMultiple?(move,user)
      target_data = move.pbTarget(user)
      return false if target_data.num_targets <= 1
      num_targets = 0
      case target_data.id
      when :UserAndAllies
        @battle.eachSameSideBattler(user) { |_b| num_targets += 1 }
      when :AllNearFoes
        @battle.eachOtherSideBattler(user) { |b| num_targets += 1 if b.near?(user) }
      when :AllFoes
        @battle.eachOtherSideBattler(user) { |_b| num_targets += 1 }
      when :AllNearOthers
        @battle.eachBattler { |b| num_targets += 1 if b.near?(user) }
      when :AllBattlers
        @battle.eachBattler { |_b| num_targets += 1 }
      end
      return num_targets > 1
    end
  
    #=============================================================================
    # Immunity to a move because of the target's ability, item or other effects
    #=============================================================================
    def pbCheckMoveImmunity(move,user,target)
      types = move.calcTypes
      typeMod = move.pbCalcTypeMod(types,user,target)
      moldBreaker = moldBreaker?(move,user)
      # Type effectiveness
      return true if Effectiveness.ineffective?(typeMod) && move.damagingMove?
      # Immunity due to ability/item/other effects
      if types.include?(:GROUND)
        return true if target.airborne? && !move.hitsFlyingTargets? && move.damagingMove?
        return true if target.hasActiveAbility?(:BEARDEDMAGNETISM) && !moldBreaker
      end
      if types.include?(:FIRE) && !moldBreaker
        return true if target.hasActiveAbility?(:FLASHFIRE) && $fefieldeffect != 39
        return true if target.hasActiveAbility?(:HEATPROOF) && [8,13,21,26,28,39,46].include?($fefieldeffect)
      end
      if types.include?(:WATER) && !moldBreaker # Xeric immunity still negated by Mold Breaker
        return true if target.hasActiveAbility?([:DRYSKIN,:STORMDRAIN,:WATERABSORB])
        return true if target.hasActiveAbility?(:WATERCOMPACTION) && $fefieldeffect == 48
        return true if target.pbHasType?(:GRASS) && $fefieldeffect == 49
      end
      if types.include?(:GRASS) && !moldBreaker
        return true if target.hasActiveAbility?(:SAPSIPPER) && $fefieldeffect != 11
      end
      if types.include?(:ELECTRIC) && !moldBreaker
        return true if target.hasActiveAbility?(:LIGHTNINGROD) && $fefieldeffect != 22
        return true if target.hasActiveAbility?(:MOTORDRIVE) && $fefieldeffect != 18 && 
                       !($fefieldeffect == 26 && target.grounded?) # Short-Circuit has 50% chance for immunity but treat as 100%
        return true if target.hasActiveAbility?(:VOLTABSORB)
      end
      if types.include?(:POISON) && !moldBreaker
        return true if target.hasActiveAbility?(:IMMUNITY) && $fefieldeffect == 11
        return true if target.hasActiveAbility?(:PASTELVEIL) && $fefieldeffect == 19
      end
      return true if !Effectiveness.super_effective?(typeMod) && target.hasActiveAbility?(:WONDERGUARD)
      if !target.opposes?(user) && move.damagingMove? && !moldBreaker
        return true if target.hasActiveAbility?(:TELEPATHY)
        return true if user.hasActiveAbility?(:ALPHABETIZATION) && user.checkAlphabetizationForm(6)
      end
      return true if move.canMagicCoat? && target.hasActiveAbility?(:MAGICBOUNCE) &&
                     target.opposes?(user) && !moldBreaker
      if move.soundMove?(user) && !moldBreaker
        return true if target.hasActiveAbility?(:SOUNDPROOF) && !($fefieldeffect == 37 &&
                       target.pbHasType?(:PSYCHIC))
        return true if target.hasActiveAbility?(:PUNKROCK) && $fefieldeffect == 6
      end
      if move.bombMove? && !moldBreaker
        return true if target.hasActiveAbility?(:BULLETPROOF)
        return true if target.hasActiveAbility?(:JUGGLING) && ![8,30].include?($fefieldeffect) # 50% chance for bounce back but treat as 100%
        return true if target.hasActiveAbility?(:RECEIVER) && $fefieldeffect == 6 # 50% chance for bounce back but treat as 100%
      end
      if move.powderMove?
        return true if target.pbHasType?(:GRASS)
        return true if target.hasActiveAbility?(:OVERCOAT) && !moldBreaker
        return true if target.hasActiveItem?(:SAFETYGOGGLES)
      end
      if move.windMove? && !moldBreaker
        return true if target.hasActiveAbility?(:AIRFILTRATION)
      end
      if move.slashingMove? && !moldBreaker
        return true if $fefieldeffect == 31 && target.effects[PBEffects::FairyTaleRoles].include?(4) # 50% chance for bounce back but treat as 100%
      end
      return true if user.pbHasType?(:BUG) && target.hasActiveAbility?(:FLYTRAP) &&
                     (move.pbContactMove?(user) || [15,47].include?($fefieldeffect)) &&
                     !moldBreaker && $fefieldeffect != 22
      return true if target.effects[PBEffects::Substitute]>0 && move.statusMove? &&
                     !move.ignoresSubstitute?(user) && user.index!=target.index
      # Prankster considered in pbGetMoveScore
      return false
    end
  
    #=============================================================================
    # Get approximate properties for a battler
    #=============================================================================
  =begin
    def pbRoughTypes(move,user)
      return move.pbCalcTypes(user) # Rainbow random type still chooses a random one for calculation
    end
  =end
    
    # Returns effective attacking stat without crit and with crit
    def attackingStats(move,user,target)
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      atk, atkStage = move.pbGetAttackStats(user,target)
      critAtk = atk
      if atkStage > 6
        if target.hasActiveAbility?(:BIGPECKS) && move.physicalMove? || target.hasActiveAbility?(:INNERFOCUS) &&
           $fefieldeffect == 5
          atkStage = 6
        end
        if target.hasActiveAbility?(:DIVINE) && move.specialMove?
          atkStage = 6
        end
      end
      if !(target.hasActiveAbility?(:UNAWARE) && $fefieldeffect != 1 || target.hasActiveAbility?(:INNERFOCUS) &&
         $fefieldeffect == 5) || moldBreaker?(move,user)
        critAtkStage = [6,atkStage].max
        atk = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
        critAtk = (atk.to_f*stageMul[critAtkStage]/stageDiv[critAtkStage]).floor
      end
      return atk, critAtk
    end
    
    # Returns effective defending stat without crit and with crit
    def defendingStats(move,user,target)
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      defense, defStage = move.pbGetDefenseStats(user,target)
      critDefense = defense
      if defStage > 6
        if target.hasActiveAbility?(:HYPERCUTTER) && move.physicalMove? || target.hasActiveAbility?(:EMPYREAN) &&
           move.specialMove?
          defStage = 6
        end
      end
      if !(user.hasActiveAbility?(:UNAWARE) && $fefieldeffect != 1 || user.hasActiveAbility?(:INNERFOCUS) &&
         $fefieldeffect == 5)
        critDefStage = [6,defStage].min
        defense = (defense.to_f*stageMul[defStage]/stageDiv[defStage]).floor
        critDefense = (defense.to_f*stageMul[critDefStage]/stageDiv[critDefStage]).floor
      end
      return defense, critDefense
    end
  =begin
    def pbRoughStat(battler,stat,skill)
      return battler.pbSpeed if skill>=PBTrainerAI.highSkill && stat==:SPEED
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      stage = battler.stages[stat]+6
      value = 0
      case stat
      when :ATTACK          then value = battler.attack
      when :DEFENSE         then value = battler.defense
      when :SPECIAL_ATTACK  then value = battler.spatk
      when :SPECIAL_DEFENSE then value = battler.spdef
      when :SPEED           then value = battler.speed
      end
      return (value.to_f*stageMul[stage]/stageDiv[stage]).floor
    end
  =end
    #=============================================================================
    # Get a better move's base damage value
    #=============================================================================
    def pbMoveBaseDamage(callMove,realMove,user,target)
      baseDmg = callMove.baseDamage
      case callMove.function
      when getFunctionCode(:GUST), getFunctionCode(:TWISTER)
        baseDmg = callMove.pbBaseDamage(baseDmg,user,target) if target.shouldMoveAfter?(user,realMove)
      when getFunctionCode(:FUSIONBOLT)
      when getFunctionCode(:FUSIONFLARE)
      when getFunctionCode(:AVALANCHE)
        baseDmg *= 1.5 / @battle.pbSideBattlerCount(user) # Assumes 75% chance to use damaging move
      when getFunctionCode(:ASSURANCE)
      when getFunctionCode(:ROUND)
      when getFunctionCode(:PAYBACK)
        baseDmg *= 2 if target.shouldMoveBefore?(user,realMove)
      #when getFunctionCode(:PURSUIT) # Too hard to predict switches
      when getFunctionCode(:PRESENT)
        baseDmg = 50
      when getFunctionCode(:MAGNITUDE),getFunctionCode(:TSUNAMI)
        baseDmg = 71
      when getFunctionCode(:FISHIOUSREND)
        baseDmg *= 2 if target.shouldMoveAfter?(user,realMove)
      when getFunctionCode(:LASHOUT)
      when getFunctionCode(:BEATUP),getFunctionCode(:CHAINLIGHTNING)
        baseDmg = 10
      when getFunctionCode(:DRAGONFLEET)
        baseDmg = 20
      else
        if callMove.function != getFunctionCode(:TRIPLEKICK) # Triple Kick's base damage changes per hit
          baseDmg = callMove.pbBaseDamage(baseDmg,user,target)
          baseDmg = callMove.pbBaseDamageMultiplier(baseDmg,user,target)
        end
      end
      case callMove.function
      when getFunctionCode(:TRIPLEKICK)
        baseDmg *= 6
      when getFunctionCode(:FURYATTACK)
        if user.hasActiveAbility?(:SKILLLINK)
          baseDmg *= 5
        elsif user.hasActiveAbility?(:BATTLEBOND) && callMove.id == :WATERSHURIKEN
          baseDmg *= 3
        else
          baseDmg = baseDmg * 19 / 6
        end
      else # Damage is same for each hit (or is Beat Up/Chain Lightning/Dragon Fleet)
        numHits = getNumHits(callMove,user,target)
        if numHits > 1 || !user.hasActiveAbility?(:PARENTALBOND) || callMove.pbTarget(user).num_targets > 1
          baseDmg *= numHits
        else
          baseDmg *= 1.25 # Parental Bond extra hit
        end
      end
      return baseDmg
    end
    #=============================================================================
    # Damage calculation
    #=============================================================================
    # Determines the amount of damage that is expected to be inflicted by the given
    # user against the given target assuming the move hits.  sureCrit determines whether
    # to estimate damage as if the move lands as a critical hit.
    def pbRoughDamage(callMove,realMove,user,target,sureCrit=false,showLog=false,calcLaterDamage=false)
      if callMove.baseDamage == 0 || callMove.function == getFunctionCode(:POLLENPUFF) &&
         !user.opposes?(target)
        echo("\n[AI - #{Time.now - $time}] Rough damage for #{callMove.name} is 0 because it isn't damaging.") if showLog
        return 0
      elsif !calcLaterDamage && (callMove.function == getFunctionCode(:FUTURESIGHT) || 
            callMove.pbIsChargingTurn?(user))
        echo("\n[AI - #{Time.now - $time}] Rough damage for #{callMove.name} is 0 because it won't deal damage immediately.") if showLog
        return 0
      end
      echo("\n[AI - #{Time.now - $time}] Starting average damage check for #{user.pbThis(true)}'s #{callMove.name}") if showLog
      if target.nil? # Counter, Mirror Coat, Metal Burst, etc.
        echo(".") if showLog
      else
        echo(" against #{target.pbThis(true)}.") if showLog
      end
      # Fixed damage moves
      if callMove.is_a?(PokeBattle_FixedDamageMove)
        # Account for variation with some fixed damage moves
        case callMove.function
        when getFunctionCode(:PSYWAVE)
          damage = user.level
          if $fefieldeffect == 21
            damage = (damage * 1.3).round
          elsif $fefieldeffect == 37
            damage = (damage * 1.5).round
          end
        # Counter/Mirror Coat/Metal Burst don't call this method by core, but can still be invoked
        when getFunctionCode(:COUNTER)
          # Note that Counter deals damage based on last hit to Counter user
          # Takes a weighted average of all the damages the opponents' moves
          # First order all damages that can be dealt in descending order
          damages = []
          user.eachNearOpposing do |b|
            for m in b.knownMoves
              if m.pp > 0 && m.physicalMove? && !getVariableFixedFunctions.include?(m.function) &&
                 b.movesBefore?(m,user,realMove)
                temp = pbRoughDamage(m,m,b,user,b.hp,userMTHP)
                added = false
                for i in 0...damages.length
                  if damages[i] < temp
                    damages.insert(i,temp)
                    added = true
                  end
                end
                if !added
                  damages.push(temp)
                end
              end
            end
          end
          # Weight using infinite series (1/2)^n from 0 to infinity -> 2
          damage = 0
          for i in 0...damages.length
            damage += damages[i]/(2**i) # Each descending damage after the first counts for half the weight of the one before it
          end
        when getFunctionCode(:MIRRORCOAT)
          # Note that Mirror Coat deals damage based on last hit to Mirror Coat user
          # Takes a weighted average of all the damages the opponents' moves
          # First order all damages that can be dealt in descending order
          damages = []
          user.eachNearOpposing do |b|
            for m in b.knownMoves
              if m.pp > 0 && m.specialMove? && !getVariableFixedFunctions.include?(m.function) &&
                 b.movesBefore?(m,user,realMove)
                temp = pbRoughDamage(m,m,b,user,b.hp,userMTHP)
                added = false
                for i in 0...damages.length
                  if damages[i] < temp
                    damages.insert(i,temp)
                    added = true
                  end
                end
                if !added
                  damages.push(temp)
                end
              end
            end
          end
          # Weight using infinite series (1/2)^n from 0 to infinity -> 2
          damage = 0
          for i in 0...damages.length
            damage += damages[i]/(2**i) # Each descending damage after the first counts for half the weight of the one before it
          end
        when getFunctionCode(:METALBURST)
          # Note that Metal Burst deals damage based on last hit to Metal Burst user
          # Takes a weighted average of all the damages the opponents' moves
          # First order all damages that can be dealt in descending order
          damages = []
          user.eachNearOpposing do |b|
            for m in b.knownMoves
              if m.pp > 0 && !getVariableFixedFunctions.include?(m.function) &&
                 b.movesBefore?(m,user,realMove)
                temp = pbRoughDamage(m,m,b,user,b.hp,userMTHP)
                added = false
                for i in 0...damages.length
                  if damages[i] < temp
                    damages.insert(i,temp)
                    added = true
                  end
                end
                if !added
                  damages.push(temp)
                end
              end
            end
          end
          # Weight using infinite series (1/2)^n from 0 to infinity -> 2
          damage = 0
          for i in 0...damages.length
            damage += damages[i]/(2**i) # Each descending damage after the first counts for half the weight of the one before it
          end
          damage = damage*3/4 # For total of x1.5 average damage
        when getFunctionCode(:SUPERFANG)
          if callMove.id == :NATURESMADNESS
            if [2,15,33,39,42].include?($fefieldeffect)
              damage = (target.hp*2/3.0).round
            elsif $fefieldeffect == 38
              damage = (target.hp/3.0).round
            end
          end
          damage = (target.hp/2.0).round
        when getFunctionCode(:ENDEAVOR)
          damage = target.hp - user.hp
        when getFunctionCode(:BIDE)
          damage = 0 # Needs to be 0 so that we know damage isn't inflicted on turn of selection
        when getFunctionCode(:FINALGAMBIT)
          if [6,31].include?($fefieldeffect)
            damage = user.hp * 1.5
          elsif [29,45].include?($fefieldeffect)
            damage = user.hp * 2
          else
            damage = user.hp
          end
        else 
          damage = callMove.pbFixedDamage(user,target)
        end
        echo("\n[AI - #{Time.now - $time}] Final damage is #{damage} (fixed damage move).") if showLog
        return damage
      end
      moldBreaker = moldBreaker?(callMove,user)
      if moldBreaker
        echo("\n[AI - #{Time.now - $time}] Either #{user.pbThis(true)} has Mold Breaker or #{callMove.name} ignores abilities.") if showLog
      end
      # Set up move attributes for proper calculation
      case callMove.function
      when getFunctionCode(:PHOTONGEYSER)
        stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
        stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
        atk        = user.attack
        atkStage   = user.stages[:ATTACK]+6
        realAtk    = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
        if $fefieldeffect == 24
          spAtk      = [user.spatk,user.spdef].max
          spAtkStage = [user.stages[:SPECIAL_ATTACK],user.stages[:SPECIAL_DEFENSE]].max+6
        else
          spAtk      = user.spatk
          spAtkStage = user.stages[:SPECIAL_ATTACK]+6
        end
        realSpAtk  = (spAtk.to_f*stageMul[spAtkStage]/stageDiv[spAtkStage]).floor
        callMove.setCalcCategory((realAtk > realSpAtk) ? 0 : 1)
      when getFunctionCode(:SHELLSIDEARM)
        if callMove.pbTarget(user).num_targets == 1
          stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
          stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
          defense      = target.defense
          defenseStage = target.stages[:DEFENSE]+6
          realDefense  = (defense.to_f*stageMul[defenseStage]/stageDiv[defenseStage]).floor
          if $fefieldeffect == 24
            spdef        = [target.spdef,targets[0].spatk].max
            spdefStage   = [target.stages[:SPECIAL_ATTACK],target.stages[:SPECIAL_DEFENSE]].max+6
          else
            spdef        = target.spdef
            spdefStage   = target.stages[:SPECIAL_DEFENSE]
          end
          realSpdef    = (spdef.to_f*stageMul[spdefStage]/stageDiv[spdefStage]).floor
          # Determine move's category
          callMove.setCalcCategory((realDefense < realSpdef) ? 0 : 1)
        end
      end
      # Determine critical hit modifiers (and change sureCrit accordingly)
      c = criticalHitRate(callMove,user,target,moldBreaker)
      echo("\n[AI - #{Time.now - $time}] #{callMove.name}'s critical hit rate is determined to be #{c}.") if showLog
      if c >= 3
        sureCrit = true
        echo("\n[AI - #{Time.now - $time}] #{callMove.name} will be a critical hit.") if showLog
      end
      baseDmg = pbMoveBaseDamage(callMove,realMove,user,target)
      echo("\n[AI - #{Time.now - $time}] Base power is set to #{baseDmg}.") if showLog
      # Get the move's type
      types = callMove.calcTypes.nil? ? callMove.pbCalcTypes(user) : callMove.calcTypes
      if showLog
        echo("\n[AI - #{Time.now - $time}] #{callMove.name} was determined to be") if showLog
        for i in 0...types.length
          if i == 0
            echo(" #{GameData::Type.get(types[i]).name}-") if showLog
          elsif i == types.length - 1
            if i == 1
              echo(" and #{GameData::Type.get(types[i]).name}-") if showLog
            else
              echo(", and #{GameData::Type.get(types[i]).name}-") if showLog
            end
          else
            echo(", #{GameData::Type.get(types[i]).name}-") if showLog
          end
          if i == types.length - 1
            echo("type.") if showLog
          end
        end
      end
      typeMod = callMove.pbCalcTypeMod(types,user,target)
      ##### Calculate user's attack stat #####
      atk, critAtk = attackingStats(callMove,user,target)
      ##### Calculate target's defense stat #####
      defense, critDefense = defendingStats(callMove,user,target)
      ##### Calculate all multiplier effects #####
      multipliers = {
        :base_damage_multiplier  => 1.0,
        :attack_multiplier       => 1.0,
        :defense_multiplier      => 1.0,
        :final_damage_multiplier => 1.0
      }
      criticalMultipliers = {
        :base_damage_multiplier  => 1.0,
        :attack_multiplier       => 1.0,
        :defense_multiplier      => 1.0,
        :final_damage_multiplier => 1.0
      }
      # Ability effects that alter damage
      # Global Abilities
      callMove.pbCalcGlobalAbilityMultipliers(user,target,types,multipliers)
      if @battle.pbCheckGlobalAbility(:VANGUARD) && $fefieldeffect != 37
        if $fefieldeffect == 36
          if user.movesLast?(user,realMove)
            multipliers[:base_damage_multiplier] *= 1.5
          end
        else
          if user.movesFirst?(user,realMove)
            multipliers[:base_damage_multiplier] *= 1.5
          end
        end
      end
      # User Ability
      callMove.pbCalcUserAbilityMultipliers(user,target,types,multipliers,baseDmg)
      multipliers[:base_damage_multiplier] *= callMove.powerBoost # Should work because we already did pbCalcTypes
      if user.hasActiveAbility?(:ANALYTIC) && target.shouldMoveBefore?(user,realMove)
        if [17,44].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] *= 1.5
        else
          multipliers[:base_damage_multiplier] *= 1.3
        end
      end
      if user.hasActiveAbility?(:NEUROFORCE) && Effectiveness.super_effective?(typeMod) &&
         $fefieldeffect != 45
        multipliers[:final_damage_multiplier] *= 1.25
      end
      if user.hasActiveAbility?(:SNIPER)
        if [22,27,28,43].include?($fefieldeffect)
          criticalMultipliers[:final_damage_multiplier] *= 2
        else
          criticalMultipliers[:final_damage_multiplier] *= 1.5
        end
      end
      if user.hasActiveAbility?(:CRITICALSTALK) && physicalMove?
        criticalMultipliers[:attack_multiplier] *= 2
      end
      if user.hasActiveAbility?(:STAKEOUT) && target.turnCount <= 1 && [4,14,40].include?($fefieldeffect)
        # Doesn't account for switches
        multipliers[:base_damage_multiplier] *= 2
      end
      if user.hasActiveAbility?(:TINTEDLENS) && Effectiveness.resistant?(typeMod) &&
         ![4,18].include?($fefieldeffect)
        multipliers[:final_damage_multiplier] *= 2
      end
      if user.hasActiveAbility?(:SNEAKATTACK) && $fefieldeffect == 40
        criticalMultipliers[:final_damage_multiplier] *= 1.5
      end
      if user.hasActiveAbility?(:ALPHABETIZATION)
        if user.checkAlphabetizationForm(17)# && user.tookDamage
          #multipliers[:attack_multiplier] *= 4
        end
      end
      if user.hasActiveAbility?(:SHIFU)
        if callMove.kickingMove? && realMove.id == user.lastMoveUsed
          multipliers[:base_damage_multiplier] *= 1 + 0.1*user.effects[PBEffects::Shifu]
        end
      end
      if !moldBreaker
        # User Ally Ability
        callMove.pbCalcUserAllyAbilityMultipliers(user,target,types,multipliers)
        # Target Ability
        callMove.pbCalcTargetAbilityMultipliers(user,target,types,multipliers)
        if target.hasActiveAbility?(:FILTER) && Effectiveness.super_effective?(typeMod)
          if $fefieldeffect == 44
            multipliers[:final_damage_multiplier] *= 0.5
          else
            multipliers[:final_damage_multiplier] *= 0.75
          end
        end
        if target.hasActiveAbility?(:SOLIDROCK) && Effectiveness.super_effective?(typeMod) &&
           ![7,35].include?($fefieldeffect)
          if [4,14,23,25,27,41].include?($fefieldeffect)
            multipliers[:final_damage_multiplier] *= 0.5
          else
            multipliers[:final_damage_multiplier] *= 0.75
          end
        end
        if target.hasActiveAbility?(:TINTEDLENS) && Effectiveness.super_effective?(typeMod) &&
           $fefieldeffect == 34
          multipliers[:final_damage_multiplier] *= 0.5
        end
        callMove.pbCalcTargetAllyAbilityMultipliers(user,target,types,multipliers)
      end
      # Target Ability (Non-Ignorable)
      callMove.pbCalcTargetAbilityNonIgnorableMultipliers(user,target,types,multipliers)
      if target.hasActiveAbility?(:PRISMARMOR) && !($fefieldeffect == 26 && target.grounded?)
        if Effectiveness.super_effective?(typeMod)
          multipliers[:final_damage_multiplier] *= 0.75
        end
        if [4,9,25].include?($fefieldeffect)
          multipliers[:defense_multiplier] *= 2
        end
      end
      # Items
      if user.itemActive?
        case user.item
        when :EXPERTBELT
          if Effectiveness.super_effective?(typeMod)
            if $fefieldeffect == 45
              mults[:final_damage_multiplier] *= 1.5
            else
              mults[:final_damage_multiplier] *= 1.2
            end
          end
        else
          BattleHandlers.triggerDamageCalcUserItem(user.item,user,target,callMove,multipliers,baseDmg,types)
        end
      end
      if target.itemActive?
        case target.item
        when :BABIRIBERRY
          if types.include?(:STEEL) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :CHARTIBERRY
          if types.include?(:ROCK) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :CHILANBERRY
          if types.include?(:NORMAL)
            weaknessBerryMult(multipliers,target)
          end
        when :CHOPLEBERRY
          if types.include?(:FIGHTING) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :COBABERRY
          if types.include?(:FLYING) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :COLBURBERRY
          if types.include?(:DARK) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :HABANBERRY
          if types.include?(:DRAGON) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :KASIBBERRY
          if types.include?(:GHOST) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :KEBIABERRY
          if types.include?(:POISON) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :OCCABERRY
          if types.include?(:FIRE) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :PASSHOBERRY
          if types.include?(:WATER) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :PAYAPABERRY
          if types.include?(:PSYCHIC) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :RINDOBERRY
          if types.include?(:GRASS) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :ROSELIBERRY
          if types.include?(:FAIRY) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :SHUCABERRY
          if types.include?(:GROUND) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :TANGABERRY
          if types.include?(:BUG) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :WACANBERRY
          if types.include?(:ELECTRIC) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        when :YACHEBERRY
          if types.include?(:ICE) && Effectiveness.super_effective?(typeMod)
            weaknessBerryMult(multipliers,target)
          end
        else
          BattleHandlers.triggerDamageCalcTargetItem(target.item,user,target,callMove,multipliers,baseDmg,types)
        end
      end
      # General
      callMove.pbCalcGeneralMultipliers(user,target,types,multipliers,moldBreaker)
      # Parental Bond
      if user.hasActiveAbility?(:PARENTALBOND)
        if [29,31].include?($fefieldeffect)
          multipliers[:base_damage_multiplier] *= 1.5
        else
          multipliers[:base_damage_multiplier] *= 1.25
        end
      end
      # Me First - handled in function code (status move not running through this code)
      # Field Effects
      callMove.pbCalcFieldMultipliers(user,target,types,multipliers,false)
      case $fefieldeffect
      when 6 # Performance Stage
        if types.include?(:FIGHTING) && callMove.physicalMove? || [:STRENGTH,:WOODHAMMER,
           :DUALCHOP,:HEATCRASH,:SKYDROP,:ICICLECRASH,:BODYSLAM,:STOMP,:GIGAIMPACT,
           :POUND,:SMACKDOWN,:IRONTAIL,:KNOCKOFF,:CRABHAMMER,:DRAGONRUSH,:BOUNCE,:SLAM,
           :HEAVYSLAM,:HIGHHORSEPOWER,:ICEHAMMER,:DRAGONHAMMER,:BRUTALSWING,:STOMPINGTANTRUM,
           :SUCKERPUNCH,:ROCKSLIDE,:AVALANCHE,:THROATCHOP,:LUNGE,:SUNSTEELSTRIKE,:BEHEMOTHBASH,
           :GRAVAPPLE,:CONTINENTALCRUSH,:CORKSCREWCRASH,:SUBZEROSLAMMER,:PULVERIZINGPANCAKE,
           :SEARINGSUNRAZESMASH].include?(@id)
          if user.hasActiveAbility?([:HUGEPOWER,:GUTS,:PUREPOWER,:SHEERFORCE,:STEADFAST,
             :IRONFIST,:SUPERLUCK,:COMPETITIVE,:GORILLATACTICS])
            strikeValue = 12
          else
            strikeValue = 8
          end
          strikeValue += user.stages[:ATTACK]
          if strikeValue >= 15
            multipliers[:base_damage_multiplier] *= 3
          elsif strikeValue >= 13
            multipliers[:base_damage_multiplier] *= 2
          elsif strikeValue >= 9
            multipliers[:base_damage_multiplier] *= 1.5
          elsif strikeValue < 3
            multipliers[:base_damage_multiplier] *= 0.5
          end
        end
      when 13 # Icy Cave
        # NeverMiss effect - considered in accuracy miss modifier
      when 18 # Short-Circuit Field
        if types.include?(:ELECTRIC)
          if [:THUNDERSHOCK,:SPARK,:ELECTROBALL,:VOLTSWITCH,:CHAINLIGHTNING].include?(@id)
            strikeValue = 4
          else
            strikeValue = @battle.field.effects[PBEffects::StrikeValue]
            for hit in hitsBeforeActionInOrder(user,realMove)
              if [:THUNDERSHOCK,:SPARK,:ELECTROBALL,:VOLTSWITCH,:CHAINLIGHTNING].include?(hit.id)
                strikeValue = 4
              elsif hit.pbCalcTypes.include?(:ELECTRIC)
                strikeValue = (strikeValue + 1) % 6
              end
            end
            strikeValue += 1
          end
          case strikeValue
          when 0
            multipliers[:base_damage_multiplier] *= 0.8
          when 2
            multipliers[:base_damage_multiplier] *= 1.2
          when 3
            multipliers[:base_damage_multiplier] *= 1.5
          when 4
            multipliers[:base_damage_multiplier] *= 2
          when 5
            multipliers[:base_damage_multiplier] *= 0.5
          end # when 1, x1
        end
      when 40 # Haunted Field
        if user.effects[PBEffects::HauntedScared] == target.index
          multipliers[:base_damage_multiplier] *= 0.5
        end
        if target.effects[PBEffects::HauntedScared] == user.index
          multipliers[:base_damage_multiplier] *= 1.5
        end
      when 48 # Beach
        if [:SURF,:SLUDGEWAVE,:MUDDYWATER,:THOUSANDWAVES,:STOKEDSPARKSURFER,:SHOCKWAVE].include?(@id)
          if user.hasActiveAbility?([:COMPETITIVE,:DANCER,:LIMBER,:SCHOOLING,:SERENEGRACE,
             :SURGESURFER,:OWNTEMPO,:SWIFTSWIM,:WAVERIDER])
            strikeValue = 12
          else
            strikeValue = 8
          end
          strikeValue += user.stages[:ACCURACY]
          if strikeValue >= 15
            multipliers[:base_damage_multiplier] *= 3
          elsif strikeValue >= 13
            multipliers[:base_damage_multiplier] *= 2
          elsif strikeValue >= 9
            multipliers[:base_damage_multiplier] *= 1.5
          elsif strikeValue < 3
            multipliers[:base_damage_multiplier] *= 0.5
          end
        end
      end
      # Critical hits
      if $fefieldeffect == 24
        criticalMultipliers[:final_damage_multiplier] *= (2.0*user.level+5.0)/(user.level+5.0)
      else
        criticalMultipliers[:final_damage_multiplier] *= 1.5
      end
      # Random variance
      multipliers[:final_damage_multiplier] *= 0.925
      # Dragon Darts - considered in base damage (with numHits)
      # Type effectiveness
      multipliers[:final_damage_multiplier] *= typeMod / Effectiveness::NORMAL_EFFECTIVE
      # Aurora Veil, Reflect, Light Screen
      if !callMove.ignoresReflect?(user)
        if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
          if @battle.pbSideBattlerCount(target)>1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
            criticalMultipliers[:final_damage_multiplier] *= 3 / 2.0 # Goes through screen
          else
            multipliers[:final_damage_multiplier] /= 2
            criticalMultipliers[:final_damage_multiplier] *= 2 # Goes through screen
          end
        elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && callMove.physicalMove?
          if @battle.pbSideBattlerCount(target)>1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
            criticalMultipliers[:final_damage_multiplier] *= 3 / 2.0 # Goes through screen
          else
            multipliers[:final_damage_multiplier] /= 2
            criticalMultipliers[:final_damage_multiplier] *= 2 # Goes through screen
          end
        elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && callMove.specialMove?
          if @battle.pbSideBattlerCount(target) > 1
            multipliers[:final_damage_multiplier] *= 2 / 3.0
            criticalMultipliers[:final_damage_multiplier] *= 3 / 2.0 # Goes through screen
          else
            multipliers[:final_damage_multiplier] /= 2
            criticalMultipliers[:final_damage_multiplier] *= 2 # Goes through screen
          end
        end
      end
      # Multi-targeting attacks
      if pbTargetsMultiple?(callMove,user)
        multipliers[:final_damage_multiplier] *= 0.75
      end
      # Move-specific final damage modifiers
      case callMove.function
      when getFunctionCode(:SURF),getFunctionCode(:EARTHQUAKE),getFunctionCode(:MAGNITUDE),
           getFunctionCode(:WHIRLPOOL),getFunctionCode(:TSUNAMI)
        multipliers[:final_damage_multiplier] = callMove.pbModifyDamage(multipliers[:final_damage_multiplier],user,target) if target.shouldMoveAfter?(user,realMove)
      else
        multipliers[:final_damage_multiplier] = callMove.pbModifyDamage(multipliers[:final_damage_multiplier],user,target)
      end
      echo("\n[AI - #{Time.now - $time}] Base Damage Multiplier: #{multipliers[:base_damage_multiplier]}.") if showLog
      echo("\n[AI - #{Time.now - $time}] #{user.pbThis}'s Attack Multiplier: #{multipliers[:attack_multiplier]}.") if showLog
      echo("\n[AI - #{Time.now - $time}] #{target.pbThis}'s Defense Multiplier: #{multipliers[:defense_multiplier]}.") if showLog
      echo("\n[AI - #{Time.now - $time}] Final Damage Multiplier: #{multipliers[:final_damage_multiplier]}.") if showLog
      ##### Main damage calculation #####
      baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
      atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
      defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
      damage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
      damage  = [(damage  * multipliers[:final_damage_multiplier]).round, 1].max
      echo("\n[AI - #{Time.now - $time}] Expected damage after multipliers: #{damage}.") if showLog
      # Increased critical hit rates
      ratios = [24,8,2,1]
      if c >= 0 && !sureCrit
        baseDmg = [(baseDmg * criticalMultipliers[:base_damage_multiplier] * multipliers[:base_damage_multiplier]).round, 1].max
        critAtk = [(critAtk * criticalMultipliers[:attack_multiplier] * multipliers[:attack_multiplier]).round, 1].max
        critDefense = [(critDefense * criticalMultipliers[:defense_multiplier] * multipliers[:defense_multiplier]).round, 1].max
        critDamage  = (((2.0 * user.level / 5 + 2).floor * baseDmg * critAtk / critDefense).floor / 50).floor + 2
        critDamage  = [(critDamage * criticalMultipliers[:final_damage_multiplier] * multipliers[:final_damage_multiplier]).round, 1].max
        echo("\n[AI - #{Time.now - $time}] Expected damage for a critical hit: #{critDamage}.") if showLog
        oldDamage = damage
        critChance = 1.0 / ratios[c]
        damage *= 1 - critChance # Multiply non-crit damage by chance it will be non-crit
        critDamage *= critChance # Add critical component to get average
        damage += critDamage
        echo("\n[AI - #{Time.now - $time}] The chance of landing a critical hit is #{critChance}, replacing non-crit damage for crit damage with a net increase of #{damage-oldDamage} (for proper average damage).") if showLog
      end
      echo("\n[AI - #{Time.now - $time}] Final expected average damage for #{callMove.name} was determined to be #{damage.floor}.") if showLog
      return [damage.floor,target.hp].min
    end
  
    #=============================================================================
    # Accuracy calculation
    #=============================================================================
    def pbRoughAccuracy(callMove,realMove,user,target)
      return 100 if target.nil?
      # "Always hit" effects and "always hit" accuracy
      return 100 if target.effects[PBEffects::Minimize] && callMove.tramplesMinimize?(1)
      return 100 if target.effects[PBEffects::Telekinesis]>0
      # Get the move's type
      types = callMove.calcTypes.nil? ? callMove.pbCalcTypes(user) : callMove.calcTypes
      baseAcc = callMove.pbBaseAccuracy(user,target,types) # Thunder/Sun etc.
      return 100 if baseAcc == 0
      # Calculate all modifier effects
      modifiers = {}
      modifiers[:base_accuracy]  = baseAcc
      modifiers[:accuracy_stage] = user.stages[:ACCURACY]
      modifiers[:evasion_stage]  = target.stages[:EVASION]
      modifiers[:accuracy_multiplier] = 1.0
      modifiers[:evasion_multiplier]  = 1.0
      callMove.pbCalcAccuracyModifiers(user,target,modifiers,types,moldBreaker?(callMove,user))
      if user.hasActiveItem?(:ZOOMLENS) && target.shouldMoveBefore?(user,realMove)
        modifiers[:accuracy_multiplier] *= 1.2
      end
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::Foresight] && modifiers[:evasion_stage] > 0
      modifiers[:evasion_stage] = 0 if target.effects[PBEffects::MiracleEye] && modifiers[:evasion_stage] > 0
      if user.hasActiveItem?(:MICLEBERRY) && user.canConsumePinchBerry?(true,user.hp)
        modifiers[:accuracy_multiplier] *= 1.2
      end
      # Check if move can't miss
      return 100 if modifiers[:base_accuracy] == 0
      # Calculation
      accStage = [[modifiers[:accuracy_stage], -6].max, 6].min + 6
      evaStage = [[modifiers[:evasion_stage], -6].max, 6].min + 6
      stageMul = [3,3,3,3,3,3, 3, 4,5,6,7,8,9]
      stageDiv = [9,8,7,6,5,4, 3, 3,3,3,3,3,3]
      accuracy = 100.0 * stageMul[accStage] / stageDiv[accStage]
      evasion  = 100.0 * stageMul[evaStage] / stageDiv[evaStage]
      accuracy = (accuracy * modifiers[:accuracy_multiplier]).round
      evasion  = (evasion  * modifiers[:evasion_multiplier]).round
      evasion = 1 if evasion<1
      ret = modifiers[:base_accuracy] * accuracy / evasion
      return ret
    end
    #=============================================================================
    # General utilities
    #=============================================================================
    # Converts a raw ratio to a skewed one to be used in calculations (must be between 0 and 1)
    def convertedRatio(ratio,exponent=4)
      if ratio < 0.5
        return (2*ratio)**exponent / 2 # ** indicates exponent function
      else # all functions with an original ratio of 0.5 converge at 0.5
        return 1 - (2*ratio - 2)**exponent / 2 # ** indicates exponent function
      end
    end
    
    # Returns -1 if move1 executes before move2, 1 if move1 executes after move2,
    # and 0 if either move could execute first
    def pbCompareMoveOrder(move1,user1,move2,user2)
      priorityDifference = pbMovePriority(move1,user1) - pbMovePriority(move2,user2)
      if priorityDifference > 0
        return -1
      elsif priorityDifference < 0
        return 1
      end
      if user1.fasterThan?(user2)
        return -1
      elsif user2.fasterThan?(user1)
        return 1
      end
      return 0 # Same speed and priority
    end
    
    # Returns the priority the given user will have using the given move (takes into
    # account subpriority using "half-steps"
    def pbMovePriority(move,user)
      pri = move.priority
      if user.hasActiveAbility?(:PRANKSTER) && move.statusMove? && $fefieldeffect != 29
        if [4,40].include?($fefieldeffect)
          pri = 1
        else
          pri += 1
        end
      end
      pri += 1 if user.hasActiveAbility?(:GALEWINGS) && (user.hp == user.totalhp ||
                  [27,28,43,48].include?($fefieldeffect) || $fefieldeffect == 16 &&
                  pbWeather == :StrongWinds) && move.types.include?(:FLYING) &&
                  ![7,13,23,41,44].include?($fefieldeffect)
      pri += 3 if user.hasActiveAbility?(:TRIAGE) && move.healingMove? && ![10,11].include?($fefieldeffect)
      pri += 1 if user.hasActiveAbility?(:SPEEDLAUNCHER) && move.pulseMove?
      pri += 1 if user.hasActiveAbility?(:SPEEDSLICE) && move.slashingMove?
      pri += 1 if user.hasActiveAbility?(:ALPHABETIZATION) && user.checkAlphabetizationForm(16)
      pri += 1 if user.hasActiveAbility?(:ARMCANNON) && $fefieldeffect == 45 &&
                  move.punchingMove?
      pri = -1 if user.hasActiveAbility?(:MARACAMOVEMENT) && move.danceMove? && ![6,22].include?($fefieldeffect)
      pri += move.pbChangePriority(user)
      subPri = 0
      if user.hasActiveAbility?(:STALL)
        subPri = -0.5 if $fefieldeffect != 1
        subPri = 0.5 if $fefieldeffect == 45
      end
      subPri = 0.5 if user.hasActiveAbility?(:QUICKDRAW) && $fefieldeffect == 5
      subPri = 0.5 if user.hasActiveAbility?(:QUEENLYMAJESTY) && ($fefieldeffect == 5 || 
                   $fefieldeffect == 33 && $fecounter == 4)
      subPri = 0.5 if user.hasActiveAbility?(:VANGUARD) && ($fefieldeffect == 5 && 
                   $fecounter%6 == 0) # Pawn
      return pri + subPri
    end
    
    # Creates a "fake" battler out of a Pokemon so that party and illusion mons can be used in calculations
    def pbMakeFakeBattler(index,pokemon,batonpass=false)
          return nil if pokemon.nil?
          battler = PokeBattle_Battler.new(@battle,index,true)
          battler.pbInitPokemon(pokemon.clone,index)
          battler.pbInitEffects(batonpass,true)
          return battler
      end
    
    # Returns the function code of the input move ID
    def getFunctionCode(move_id)
      return GameData::Move.try_get(move_id).function_code
    end
    
    # Changes to the expected field effect right before the user uses its inputted move.
    # Doesn't account for being knocked out before move executes, transformations
    # from sources other than by moves, transformations that should instead revert
    # to a backup field, or transformations that require more than one move use if
    # none of the uses have occurred yet (could cause issues)
    def changeToExpectedField(user,move)
      # Field Transformations
      return if @battle.pbCheckGlobalAbility(:AMBIENTCONNECTION) || @user.nil?
      for hit in hitsBeforeActionInOrder(user,move)
        case $fefieldeffect
        when 0 # No Field
          if hit.id == :ELECTRICTERRAIN
            $fefieldeffect = 1
          elsif hit.id == :GRASSYTERRAIN
            $fefieldeffect = 2
          elsif hit.id == :MISTYTERRAIN
            $fefieldeffect = 3
          elsif hit.id == :PSYCHICTERRAIN
            $fefieldeffect = 37
          elsif hit.id == :TOPSYTURVY
            $fefieldeffect = 36
          elsif @battle.field.effects[PBEffects::ConversionField] && [:CONVERSION,
                :CONVERSION2].include?(hit.id)
            $fefieldeffect = 24
          # Doesn't account for pledge moves
          end
        when 1 # Electric Terrain
          if [:MUDSPORT,:MUDDYWATER,:MUDBOMB].include?(hit.id)
            $fefieldeffect = 0
          end
        when 2 # Grassy Terrain
          if [:SLUDGEWAVE,:ACIDDOWNPOUR].include?(hit.id)
            $fefieldeffect = 10
          elsif [:ERUPTION,:LAVAPLUME,:FLAMEBURST,:INCINERATE,:SEARINGSHOT,:FIREPLEDGE,
                 :BURNUP,:MAGMASTORM,:INFERNOOVERDRIVE].include?(hit.id)
            $fefieldeffect = 0
          elsif hit.id == :ROTOTILLER
            $fefieldeffect = 33
          end
        when 3 # Misty Terrain
          if hit.windMove? || [:GRAVITY,:DEFOG,:CLEARSMOG,:TAILWIND].include?(hit.id)
            $fefieldeffect = 0
          elsif [:CORROSIVEGAS,:SMOG,:POISONGAS,:ACIDSPRAY].include?(hit.id) && $fecounter == 1 ||
                hit.id == :ACIDDOWNPOUR
            $fefieldeffect = 11
          end
        when 4 # Dark Crystal Cavern
          if [:SUNNYDAY,:CHARGEBEAM,:WILDCHARGE].include?(hit.id)
            $fefieldeffect = 25
          elsif [:EARTHQUAKE,:BULLDOZE,:MAGNITUDE,:SELFDESTRUCT,:EXPLOSION,:ROCKWRECKER,
                :STEELROLLER,:ALLOUTPUMMELING,:TECTONICRAGE,:CONTINENTALCRUSH].include?(hit.id)
            $fefieldeffect = 23
          end
        when 5 # Chess Board
          if [:STOMPINGTANTRUM,:TECTONICRAGE].include?(hit.id)
            $fefieldeffect = 0
          end
        when 6 # Performance Stage
          if [:STEAMROLLER,:BULLDOZE,:ROCKWRECKER].include?(hit.id)
            $fefieldeffect = 44
          elsif [:TAUNT,:TORMENT,:SWAGGER].include?(hit.id)
            $fefieldeffect == 45
          end
        when 7 # Volcanic Field
          if [:WATERSPORT,:RAINDANCE,:MUDSPORT,:SURF,:MUDDYWATER,:WATERSPOUT,:WATERPLEDGE,
             :TSUNAMI,:HYDROVORTEX,:GLACIATE,:CONTINENTALCRUSH].include?(hit.id)
            $fefieldeffect = 23
          elsif [:SLUDGEWAVE,:ACIDDOWNPOUR].include?(hit.id)
            $fefieldeffect = 41
          elsif [:DRAGONFLEET,:DEVASTATINGDRAKE].include?(hit.id)
            $fefieldeffect = 32
          end
        when 8 # Swamp
          if hit.id == :HEATWAVE
            $fefieldeffect = 0
          end
        when 9 # Rainbow Field
          if [:HAIL,:SANDSTORM,:DEFOG,:LIGHTTHATBURNSTHESKY].include?(hit.id)
            $fefieldeffect = 0
          end
        when 10 # Corrosive Field
          if [:SEEDFLARE,:PURIFY,:NATURESMADNESS,:GEOMANCY].include?(hit.id)
            $fefieldeffect = 2
          elsif [:MAGICCOAT,:PSYCHICTERRAIN,:PSYCHIC,:MAGICPOWDER,:SHATTEREDPSYCHE].include?(hit.id) &&
                $fecounter == 1
            $fefieldeffect = 19
          elsif [:MISTYTERRAIN,:CORROSIVEGAS,:MISTGUARD,:POISONGAS].include?(hit.id)
            $fefieldeffect = 11
          end
        when 11 # Corrosive Mist Field
          if hit.id == :GRAVITY
            $fefieldeffect = 10
          elsif [:LAVAPLUME,:FLAMEBURST,:SEARINGSHOT,:SELFDESTRUCT,:EXPLOSION,:ERUPTION,
                :FIREPLEDGE,:BLASTBURN,:OVERHEAT,:MAGMASTORM,:FUSIONFLARE,:BURNUP,
                :INFERNOOVERDRIVE].include?(hit.id) && !@battle.dampBattler? || [:HURRICANE,
                :WHIRLWIND,:DEFOG,:CLEARSMOG,:TAILWIND].include?(hit.id)
            $fefieldeffect = 0
          elsif [:PURIFY,:SEEDFLARE].include?(hit.id)
            $fefieldeffect = 3
          end
        when 12 # Desert
          if [:GROWTH,:ROTOTILLER,:GRASSYTERRAIN,:GEOMANCY].include?(hit.id)
            $fefieldeffect = 49
          end
        when 13 # Icy Cave
          if [:HEATWAVE,:ERUPTION,:SEARINGSHOT,:FIREPLEDGE,:LAVAPLUME,:OVEREHEAT,:BLASTBURN,
             :MAGMASTORM,:INFERNOOVERDRIVE].include?(hit.id)
            $fefieldeffect = 23
          end
        when 14 # Rocky Field
          if [:STEAMROLLER,:STEELROLLER].include?(hit.id) && $fecounter == 1
            $fefieldeffect = 0
          end
        when 15 # Forest Field
          if [:GROWTH,:GRASSYTERRAIN].include?(hit.id) && $fecounter == 1
            $fefieldeffect = 47
          elsif [:MAGICCOAT,:PSYCHICTERRAIN,:PSYCHIC,:HYPNOSIS,:NIGHTSHADE,:PSYWAVE,
                :FORESTSCURSE,:HEX,:MAGICPOWDER,:POLTERGEIST,:EERIESPELL,:NEVERENDINGNIGHTMARE,
                :TRICKORTREAT,:MAGICROOM,:TELEKINESIS].include?(hit.id)
            $fefieldeffect = 42
          end
        when 16 # Volcanic Top Field
          if [:FLY,:BOUNCE].include?(hit.id)
            $fefieldeffect = 43
          elsif hit.id == :DIG
            $fefieldeffect = 7
          elsif [:BLIZZARD,:GLACIATE,:SHEERCOLD,:SUBZEROSLAMMER].include?(hit.id)
            $fefieldeffect = 27
          end
        when 17 # Factory Field
          if [:EXPLOSION,:SELFDESTRUCT,:MAGNITUDE,:EARTHQUAKE,:FISSURE,:BULLDOZE,:TECTONICRAGE,
             :SURF,:MUDDYWATER,:TSUNAMI,:IONDELUGE,:DISCHARGE,:HYDROVORTEX,:GIGAVOLTHAVOC,
             :TENMILLIONVOLTTHUNDERBOLT,:HEATWAVE,:OVERHEAT].include?(hit.id)
            $fefieldeffect = 18
          elsif hit.id == :ELECTRICTERRAIN
            $fefieldeffect = 1
          end
        when 18 # Short-Circuit Field
          if [:IONDELUGE,:CHARGE,:ELECTRICTERRAIN,:OVERCLOCK,:PARABOLICCHARGE,:WILDCHARGE,
             :CHARGEBEAM,:AURAWHEEL,:OVERDRIVE,:TURBODRIVE,:DISCHARGE,:GIGAVOLTHAVOC].include?(hit.id)
            $fefieldeffect = 17
          end
        when 19 # Wasteland
          if hit.id == :GEOMANCY
            $fefieldeffect = 37
          end
        when 20 # Ashen Beach
          if [:MAGNITUDE,:EARTHQUAKE,:TAILWIND].include?(hit.id)
            $fefieldeffect = 48
          end
        when 21 # Water Surface
          if hit.id == :SHOREUP
            $fefieldeffect = 48
          elsif [:DIVE,:ANCHORSHOT,:GRAVITY].include?(hit.id)
            $fefieldeffect = 22
          elsif [:BLIZZARD,:GLACIATE,:SHEERCOLD].include?(hit.id)
            $fefieldeffect = 46
          elsif hit.id == :SLUDGEWAVE && $fecounter == 1 || hit.id == :ACIDDOWNPOUR
            $fefieldeffect = 26
          end
        when 22 # Underwater
          if hit.id == :SHOREUP
            $fefieldeffect = 48
          elsif [:DIVE,:SKYDROP,:FLY,:BOUNCE,:SEISMICTOSS].include?(hit.id)
            $fefieldeffect = 21
          elsif hit.id == :SLUDGEWAVE && $fecounter == 1 || hit.id == :ACIDDOWNPOUR
            $fefieldeffect = 26
          end
        when 23 # Cave
          if [:EARTHQUAKE,:MAGNITUDE,:BULLDOZE,:FISSURE,:EXPLOSION,:SELFDESTRUCT,:ROCKSLIDE,
             :TECTONICRAGE,:CONTINENTALCRUSH].include?(hit.id) && $fecounter == 1
            $fefieldeffect = 14
          elsif [:POWERGEM,:DIAMONDSTORM].include?(hit.id)
            $fefieldeffect = 25
          elsif [:ERUPTION,:LAVAPLUME].include?(hit.id)
            $fefieldeffect = 7
          elsif [:SLUDGEWAVE,:ACIDDOWNPOUR].include?(hit.id)
            $fefieldeffect = 41
          elsif [:BLIZZARD,:GLACIATE,:SHEERCOLD,:SUBZEROSLAMMER].include?(hit.id)
            $fefieldeffect = 13
          elsif [:DRAGONRAGE,:DRAGONFLEET,:DRAGONENERGY].include?(hit.id)
            $fefieldeffect = 32
          end
        when 24 # Glitch Field
          if hit.id == :REFRESH
            $fefieldeffect = 0
          end
        when 25 # Crystal Cavern
          if [:DARKPULSE,:DARKVOID,:NIGHTDAZE,:NIGHTSHADE,:LIGHTTHATBURNSTHESKY].include?(hit.id)
            $fefieldeffect = 4
          elsif [:BULLDOZE,:EARTHQUAKE,:MAGNITUDE,:EXPLOSION,:SELFDESTRUCT,:ROCKWRECKER,
                :STEELROLLER,:ALLOUTPUMMELING,:TECTONICRAGE,:CONTINENTALCRUSH].include?(hit.id)
            $fefieldeffect = 23
          end
        when 26 # Murkwater Surface
          if [:WHIRLPOOL,:BLADEMAELSTROM,:HYDROVORTEX,:SEEDFLARE,:PURIFY,:MISTYTERRAIN].include?(hit.id)
            $fefieldeffect = 21
          elsif [:BLIZZARD,:GLACIATE].include?(hit.id)
            $fefieldeffect = 46
          end
        when 27 # Mountain
          if [:FLY,:BOUNCE].include?(hit.id)
            $fefieldeffect = 43
          elsif [:BLIZZARD,:SHEERCOLD,:GLACIATE,:SUBZEROSLAMMER].include?(hit.id)
            $fefieldeffect = 28
          elsif [:ERUPTION,:LAVAPLUME].include?(hit.id)
            $fefieldeffect = 16
          elsif hit.id == :DIG
            $fefieldeffect = 23
          end
        when 28 # Snowy Mountain
          if [:FLY,:BOUNCE].include?(hit.id)
            $fefieldeffect = 43
          elsif [:HEATWAVE,:SEARINGSHOT,:FLAMEBURST,:FIREPLEDGE,:INFERNOOVERDRIVE].include?(hit.id)
            $fefieldeffect = 27
          elsif [:ERUPTION,:LAVAPLUME].include?(hit.id)
            $fefieldeffect = 16
          elsif hit.id == :DIG
            $fefieldeffect = 13
          end
        when 29 # Holy
          if [:CURSE,:PHANTOMFORCE,:TRICKORTREAT,:SHADOWFORCE,:NEVERENDINGNIGHTMARE].include?(hit.id)
            $fefieldeffect = 40
          elsif [:LIGHTTHATBURNSTHESKY,:DARKVOID].include?(hit.id)
            $fefieldeffect = 0
          elsif hit.id == :GLACIATE
            $fefieldeffect = 39
          elsif hit.id == :GRASSYTERRAIN
            $fefieldeffect = 31
          end
        when 30 # Mirror Arena
          if [:EARTHQUAKE,:BULLDOZE,:BOOMBURST,:HYPERVOICE,:MAGNITUDE,:TECTONICRAGE,
             :SONICBOOM,:SELFDESTRUCT,:EXPLOSION,:STEELROLLER,:CONTINENTALCRUSH,:SHATTEREDPSYCHE,
             :SPLINTEREDSTORMSHARDS].include?(hit.id)
            $fefieldeffect = 0
          end
        when 32 # Dragon's Den
          if hit.id == :CONTINENTALCRUSH
            $fefieldeffect = 23
          end
        when 34 # Starlight Arena
          if hit.id == :LIGHTTHATBURNSTHESKY
            $fefieldeffect = 0
          end
        when 35 # Ultra Space
          if hit.id == :GEOMANCY
            $fefieldeffect = 34
          elsif [:HYPERSPACEHOLE,:TELEPORT].include?(hit.id)
            $fefieldeffect = 0 # Actually is random, but use none for calculation
          end
        when 38 # Dimensional Field
          if [:BLIZZARD,:GLACIATE,:SHEERCOLD,:SUBZEROSLAMMER].include?(hit.id)
            $fefieldeffect = 39
          elsif hit.id == :MISTYTERRAIN
            $fefieldeffect = 0
          end
        when 39 # Frozen Dimensional Field
          if [:HEATWAVE,:OVERHEAT,:FUSIONFLARE,:INFERNOOVERDRIVE,:DARKVOID].include?(hit.id)
            $fefieldeffect = 38
          end
        when 40 # Haunted Field
          if [:JUDGMENT,:SACREDFIRE,:ORIGINPULSE,:FLASH,:DAZZLINGGLEAM,:PURIFY,:SEEDFLARE,
             :MISTYTERRAIN].include?(hit.id)
            $fefieldeffect = 29
          elsif [:IONDELUGE,:ELECTRICTERRAIN].include?(hit.id)
            $fefieldeffect = 18
          elsif [:GRASSYTERRAIN,:BLOOMDOOM].include?(hit.id)
            $fefieldeffect = 42
          elsif hit.id == :PSYCHICTERRAIN
            $fefieldeffect = 37
          end
        when 41 # Corrupted Cave
          if [:SEEDFLARE,:PURIFY,:MISTYTERRAIN,:GEOMANCY,:EARTHQUAKE,:BULLDOZE,:TECTONICRAGE].include?(hit.id)
            $fefieldeffect = 23
          elsif [:ERUPTION,:LAVAPLUME].include?(hit.id)
            $fefieldeffect = 7
          elsif [:BLIZZARD,:GLACIATE,:SHEERCOLD,:SUBZEROSLAMMER].include?(hit.id)
            $fefieldeffect = 13
          end
        when 42 # Bewitched Woods
          if [:HEALINGWISH,:PURIFY,:HEALPULSE,:FLORALHEALING,:SAFEGUARD].include?(hit.id)
            $fefieldeffect = 15
          end
        when 43 # Sky Field
          if [:INGRAIN,:SMACKDOWN,:THOUSANDARROWS].include?(hit.id)
            $fefieldeffect = 27
          elsif @id == :GRAVITY
            $fefieldeffect = 15
          elsif [:AURORABEAM,:PRISMATICLASER,:AURORAVEIL].include?(hit.id)
            $fefieldeffect = 9
          elsif [:MIST,:MISTYTERRAIN,:STRANGESTEAM,:MISTGUARD].include?(hit.id)
            $fefieldeffect = 3
          elsif [:DISCHARGE,:ELECTRICTERRAIN,:IONDELUGE].include?(hit.id)
            $fefieldeffect = 1
          end
        when 44 # Indoors
          if [:MIST,:MISTYTERRAIN,:AROMATICMIST].include?(hit.id)
            $fefieldeffect = 3
          elsif hit.id == :DECORATE
            $fefieldeffect = 6
          elsif [:SMOG,:POISONGAS,:SMOKESCREEN,:HAZE,:CORROSIVEGAS].include?(hit.id) &&
                $fecounter == 1
            $fefieldeffect = 11
          elsif hit.id == :ELECTRICTERRAIN
            $fefieldeffect = 18
          end
        when 46 # Subzero Field
          if [:OVERHEAT,:HEATWAVE,:INFERNOOVERDRIVE].include?(hit.id)
            $fefieldeffect = 21
          elsif hit.id == :DIG
            $fefieldeffect = 13
          end
        when 47 # Jungle
          if hit.slashingMove? && $fecounter == 1
            $fefieldeffect = 15
          elsif [:FORESTSCURSE,:PSYCHICTERRAIN,:NEVERENDINGNIGHTMARE].include?(hit.id)
            $fefieldeffect = 42
          end
        when 48 # Beach
          if [:LAVAPLUME,:ERUPTION].include?(hit.id)
            $fefieldeffect = 20
          elsif [:WHIRLPOOL,:DIVE].include?(hit.id)
            $fefieldeffect = 21
          end
        when 49 # Xeric Shrubland
          if hit.id == :SHOREUP
            $fefieldeffect = 48
          elsif (hit.slashingMove? || [:INFERNO,:INFERNOOVERDRIVE].include?(hit.id)) &&
                $fecounter == 1
            $fefieldeffect = 12
          end
        end
      end
    end
    
    # Changes to the expected weather right before the user uses its inputted move.
    # Doesn't account for being knocked out before move executes or transformations
    # from sources other than by moves (could cause issues).
    def changeToExpectedWeather(user,move)
      return if [:HarshSun,:HeavyRain,:StrongWinds].include?(@battle.field.weather) ||
                @user.nil?
      for hit in hitsBeforeActionInOrder(user,move)
        case hit.function
        when getFunctionCode(:RAINDANCE)
          @battle.field.weather = :Rain
        when getFunctionCode(:SUNNYDAY)
          @battle.field.weather = :Sun
        when getFunctionCode(:HAIL)
          @battle.field.weather = :Hail
        when getFunctionCode(:SANDSTORM)
          @battle.field.weather = :Sandstorm
        end
      end
    end
    
    # Returns an array containing the known finalized move choices to be used before the given user uses the given move
    def moveChoicesBeforeAction(user,move)
      choices = []
      @user.eachOwnSideBattler do |b|
        if !b.moveChoice.nil? && b.movesBefore?(b.moveChoice[:realMove],user,move)
          choices.push(b.moveChoice)
        end
      end
      return choices
    end
    
    # Returns an array containing the known finalized move choices to be used before the given user uses the given move in the order they'll be used
    def moveChoicesBeforeActionInOrder(user,move)
      order = [] # Stores arrays of user and move choice
      @user.eachOwnSideBattler do |b|
        if b.index == user.index
          bCall = move
          bReal = move
          bChoice = nil
        else
          next if b.moveChoice.nil?
          bChoice = b.moveChoice
          bCall = bChoice[:callMove]
          bReal = bChoice[:realMove]
        end
        added = false
        for i in 0...order.length
          if !b.movesAfter?(bReal,order[i][0],order[i][2])
            order.insert(i,[b,bCall,bReal,bChoice])
            added = true
            break
          end
        end
        if !added
          order.push([b,bCall,bReal,bChoice])
        end
      end
      ret = []
      for pos in order
        break if pos[0].index == user.index # Only consider hits before user moves
        ret.push(pos[3])
      end
      return ret
    end
    
    # Returns an array containing the known finalized moves to be used before the given user uses the given move
    def expectedHitsBeforeAction(user,move)
      hits = []
      @user.eachOwnSideBattler do |b|
        if !b.moveChoice.nil? && b.movesBefore?(b.moveChoice[:realMove],user,move)
          hits.push(b.moveChoice[:callMove])
        end
      end
      return hits
    end
    
    # Returns an array containing the known finalized moves to be used before the given user uses the given move in the order they'll be used
    def hitsBeforeActionInOrder(user,move)
      order = [] # Stores arrays of user and move choice
      @user.eachOwnSideBattler do |b|
        if b.index == user.index
          bCall = move
          bReal = move
          bChoice = nil
        else
          next if b.moveChoice.nil?
          bChoice = b.moveChoice
          bCall = bChoice[:callMove]
          bReal = bChoice[:realMove]
        end
        added = false
        for i in 0...order.length
          if !b.movesAfter?(bReal,order[i][0],order[i][2])
            order.insert(i,[b,bCall,bReal,bChoice])
            added = true
            break
          end
        end
        if !added
          order.push([b,bCall,bReal,bChoice])
        end
      end
      ret = []
      for pos in order
        break if pos[0].index == user.index # Only consider hits before user moves
        ret.push(pos[1])
      end
      return ret
    end
    
    # Returns an array containing the known finalized move choices to be used after (or when) the given user uses the given move
    def moveChoicesAfterAction(user,move)
      choices = []
      @user.eachOwnSideBattler do |b|
        if !b.movesBefore?(b.moveChoice[:realMove],user,move)
          choices.push(b.moveChoice)
        end
      end
      return choices
    end
    
    # Returns an array containing the function codes of fixed damage moves whose damages depend on other damages
    def getVariableFixedFunctions
      return [getFunctionCode(:COUNTER),getFunctionCode(:MIRRORCOAT),getFunctionCode(:METALBURST),
             getFunctionCode(:ENDEAVOR),getFunctionCode(:BIDE)]
    end
    
    # Returns the move (if known) that will be used directly before the given user
    # uses its given move (otherwise returns a pseudomove)
    # Uses real move (not called move) because that's what's usually considered
    def directBeforeMove(user,move)
      pseudo = PokeBattle_AI_Pseudomove.new(@battle,user,:QMARKS) # Not used for anything
      order = [] # Stores arrays of user and move
      user.eachOtherBattler do |b|
        added = false
        if b.opposes?(@user) || b.moveChoice.nil?
          bMove = pseudo
        else
          bMove = b.moveChoice[:realMove]
        end
        for i in 0...order.length
          if !b.movesAfter?(bMove,order[i][0],order[i][1])
            order.insert(i,[b,bMove])
            added = true
            break
          end
        end
        if !added
          order.push([b,bMove])
        end
      end
      # Find where user would go
      for i in 0...order.length
        if !user.movesAfter?(move,order[i][0],order[i][1])
          if i == 0
            return pseudo
          else
            return order[i-1][1] # Last mon that moves before it
          end
        end
      end
      return order[order.length-1][1] # User moves last
    end
    
    # Returns the battler that will go directly before the given user uses its given move
    def directBeforeUser(user,move)
      pseudo = PokeBattle_AI_Pseudomove.new(@battle,user,:QMARKS) # Not used for anything
      order = [] # Stores arrays of user and move
      user.eachOtherBattler do |b|
        added = false
        if b.opposes?(@user) || b.moveChoice.nil?
          bMove = pseudo
        else
          bMove = b.moveChoice[:realMove]
        end
        for i in 0...order.length
          if !b.movesAfter?(bMove,order[i][0],order[i][1])
            order.insert(i,[b,bMove])
            added = true
            break
          end
        end
        if !added
          order.push([b,bMove])
        end
      end
      # Find where user would go
      for i in 0...order.length
        if !user.movesAfter?(move,order[i][0],order[i][1])
          if i == 0
            return nil
          else
            return order[i-1][0] # Last mon that moves before it
          end
        end
      end
      return order[order.length-1][0] # User moves last
    end
    
    # Returns whether abilities will be ignored for the given move used by the given user
    def moldBreaker?(move,user)
      return user.hasMoldBreaker? || [getFunctionCode(:MOONGEISTBEAM),getFunctionCode(:PHOTONGEYSER),
             getFunctionCode(:MENACINGMOONRAZEMAELSTROM),getFunctionCode(:LIGHTTHATBURNSTHESKY)].include?(move.function)
    end
    
    # Changes the appropriate multipliers of the input multiplier hash map based on the effects of type-weakening berries
    def weaknessBerryMult(mults,target)
      if target.hasActiveAbility?(:RIPEN) && ![4,10,11,12,38,39,41,46].include?($fefieldeffect)
        if $fefieldeffect == 33 && $fecounter == 4
          mults[:final_damage_multiplier] /= 8
        elsif [2,15,47].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
          mults[:final_damage_multiplier] /= 6
        else
          mults[:final_damage_multiplier] /= 4
        end
      elsif target.hasActiveAbility?(:GLUTTONY) && ([15,47].include?($fefieldeffect) || 
            $fefieldeffect == 33 && $fecounter >= 3)
          mults[:final_damage_multiplier] /= 4
      else
        mults[:final_damage_multiplier] /= 2
      end
    end
    
    # Returns the effective critical hit rate of the user using the given move against the given target
    def criticalHitRate(move,user,target,moldBreaker)
      c = 0
      if target.pbOwnSide.effects[PBEffects::LuckyChant] > 0 || !moldBreaker && target.hasActiveAbility?([:SHELLARMOR,:BATTLEARMOR])
        return -1
      end
      if user.hasActiveAbility?(:SUPERLUCK) && $fefieldeffect != 5
        if $fefieldeffect == 9
          c += 2
        else
          c += 1
        end
      end
      if user.hasActiveAbility?(:KEENEYE) && $fefieldeffect == 5
        c += 1
      end
      if user.hasActiveAbility?(:DANCER) && $fefieldeffect == 13
        c += 1
      end
      if user.hasActiveAbility?(:HYPERCUTTER) && $fefieldeffect == 31
        c += 1
      end
      if user.hasActiveAbility?(:TINTEDLENS) && $fefieldeffect == 40
        c += 1
      end
      if user.hasActiveAbility?(:LONGREACH) && $fefieldeffect == 43
        c += 1
      end
      if user.hasActiveAbility?(:UNSEENFIST) && [18,40].include?($fefieldeffect)
        c += 2
      end
      if user.hasActiveAbility?(:SNEAKATTACK) && [4,42].include?($fefieldeffect)
        c += 1
      end
      if user.hasActiveAbility?(:STORMPREDICTION) && [:Rain,:HeavyRain].include?(@battle.pbWeather) &&
         ![38,39].include?($fefieldeffect)
        c += 2
        c += 2 if [8,21,43,48].include?($fefieldeffect)
      end
      if user.hasActiveAbility?(:CRITICALSTALK) && move.physicalMove? && $fefieldeffect == 33
        c += 1 if $fecounter >= 2
        c += 1 if $fecounter == 4
      end
      if $fefieldeffect == 34 && [:JOLLY,:QUIRKY].include?(user.pokemon.nature_id)
        c += 1
      end
      # Item effects that alter critical hit rate
      if user.itemActive?
        c = BattleHandlers.triggerCriticalCalcUserItem(user.item,user,target,c)
      end
      if target.itemActive?
        c = BattleHandlers.triggerCriticalCalcTargetItem(target.item,user,target,c)
      end
      # Field Effects that alter critical hit rate
      case $fefieldeffect
      when 14 # Rocky Field
        if [:DRILLPECK,:DRILLRUN].include?(@id)
          c += 1
        end
      when 24 # Glitch Field
        c += 1 if user.speed > target.speed
      when 30 # Mirror Arena
        c += user.stages[:EVASION] if user.stages[:EVASION] > 0
        c += user.stages[:ACCURACY] if user.stages[:ACCURACY] > 0
        c += target.stages[:EVASION] if target.stages[:EVASION] < 0
        c += target.stages[:ACCURACY] if target.stages[:ACCURACY] < 0
      end
  =begin
      # Move-specific "always/never a critical hit" effects
      case move.pbCriticalOverride(user,target)
      when 1
        c += 3
      when -1
        return -1
      end
  =end
      # Other effects
      c += 3 if user.effects[PBEffects::LaserFocus] > 0
      c += 3 if user.hasActiveAbility?(:MERCILESS) && (target.poisoned? || [10,26,41].include?($fefieldeffect) &&
                target.grounded? || [11,32,39,45].include?($fefieldeffect)) && $fefieldeffect != 9
      c += 3 if target.hasActiveAbility?(:SNIPER) && $fefieldeffect == 34
      c += 3 if target.hasActiveAbility?(:SUPERLUCK) && $fefieldeffect == 31
      c += 3 if target.hasActiveAbility?(:DUALWIELD) && $fefieldeffect != 37 && move.multiHitMove?
      c += 3 if user.hasActiveAbility?(:SPYGEAR) && user.effects[PBEffects::SpyGear] == 2 # Nictitating Precision
      c += 1 if move.highCriticalRate?
      c += user.effects[PBEffects::FocusEnergy]
      c += 1 if user.inHyperMode? && move.types.include?(:SHADOW)
      return c
    end
    
    # Returns the expected additional effect chance for the given user's move against the given target
    def additionalEffectChance(move,user,target)
      return 0 if user.hasActiveAbility?(:SHEERFORCE) || $fefieldeffect == 29 && (user.pbHasType?(:DARK) ||
                  user.pbHasType?(:GHOST)) || target && target.hasShieldDust? && !moldBreaker?(move,user)
      return move.pbAdditionalEffectChance(user,target) # Doesn't account for DCC NeverMiss
    end
    
    # Returns the move that the input move will become (for moves that call other moves)
    def changeMove(move,user)
      case move.function
      # Assist considered elsewhere
      when getFunctionCode(:COPYCAT)
        beforeUser = directBeforeUser(user,move)
        if beforeUser.nil? # User goes first
          newMove = @battle.lastMoveUsed # Symbol
          if !newMove || GameData::Move.get(newMove).zMove? || move.moveBlacklist.include?(getFunctionCode(newMove))
            return changeMoveField(move,user) # Fails
          end
          newMove = PokeBattle_Move.from_pokemon_move(@battle,Pokemon::Move.new(newMove))
          if move.zMove?
            move = PokeBattle_ZMove.from_base_move(@battle,user,newMove,GameData::PowerMove.item_from(newMove.type))
          else
            move = newMove
          end
        elsif !user.opposes?(beforeUser)
          newMove = directBeforeMove(user,move) # PokeBattle_Move
          if !newMove || newMove.zMove? || move.moveBlacklist.include?(newMove.function)
            return changeMoveField(move,user) # Fails
          end
          if move.zMove?
            move = PokeBattle_ZMove.from_base_move(@battle,user,newMove,GameData::PowerMove.item_from(newMove.type))
          else
            move = newMove
          end
        end # If user will copy opposing mon, calculate score using Copycat as base
      # Me First considered elsewhere
      # Metronome considered elsewhere
      # Mirror Move considered elsewhere
      when getFunctionCode(:NATUREPOWER)
        case $fefieldeffect
        when 0 then return changeMoveField(move,user) # Fails
        when 1 then newMove = :RISINGVOLTAGE
        when 2 then newMove = :GRASSKNOT
        when 3 then newMove = :MISTBALL
        when 4 then newMove = :PRISMATICLASER
        when 5 then newMove = :COURTCHANGE
        when 6 then newMove = :ACROBATICS
        when 7 then newMove = :MAGMASTORM
        when 8 then newMove = :MUDDYWATER
        when 9 then newMove = :AURORABEAM
        when 10 then newMove = :ACID
        when 11 then newMove = :CORROSIVEGAS
        when 12 then newMove = :SCORCHINGSANDS
        when 13 then newMove = :ICICLECRASH
        when 14 then newMove = :STONEEDGE
        when 15 then newMove = :BRANCHPOKE
        when 16 then newMove = :ERUPTION
        when 17 then newMove = :GEARGRIND
        when 18 then newMove = :EERIEIMPULSE
        when 19 then newMove = :TRASHALANCHE
        when 20 then newMove = :DUSTSTORM
        when 21 then newMove = :SPLASH
        when 22 then newMove = :FLIPTURN
        when 23 then newMove = :ROCKTOMB
        when 24 then newMove = :METRONOME
        when 25 then newMove = :POWERGEM
        when 26 then newMove = :SLUDGEWAVE
        when 27 then newMove = :ROCKSLIDE
        when 28 then newMove = :AVALANCHE
        when 29 then newMove = :JUDGMENT
        when 30 then newMove = :MIRRORLAUNCH
        when 31 then newMove = :DRAININGKISS
        when 32 then newMove = :DRACONICDISASTER
        when 33
          if $fecounter == 4
            newMove = :PETALBLIZZARD
          else
            newMove = :GROWTH
          end
        when 34 then newMove = :WISH
        when 35 then newMove = :SPACIALREND
        when 36 then newMove = :TRICKROOM
        when 37 then newMove = :PSYWAVE
        when 38 then newMove = :DARKVOID
        when 39 then newMove = :PUNISHMENT
        when 40 then newMove = :POLTERGEIST
        when 41 then newMove = :SLUDGE
        when 42 then newMove = :MAGICALLEAF
        when 43 then newMove = :SKYATTACK
        when 44 then newMove = :TEATIME
        when 45 then newMove = :SUBMISSION
        when 46 then newMove = :GLACIATE
        when 47 then newMove = :JUNGLEHEALING
        when 48 then newMove = :TSUNAMI
        when 49 then newMove = :NEEDLEARM
        end
        newMove = PokeBattle_Move.from_pokemon_move(@battle,Pokemon::Move.new(newMove))
        if move.zMove?
          move = PokeBattle_ZMove.from_base_move(@battle,user,newMove,GameData::PowerMove.item_from(newMove.type))
        else
          move = newMove
        end
      # Sleep Talk considered elsewhere
      # Snatch considered elsewhere
      end
      return changeMoveField(move,user)
    end
    
    # Returns the move that the input move will become (for moves that call other moves)
    # Assumes that the new move will be used back at the original target (not always the case)
    def changeMoveAfterTargetChosen(move,user,target)
      case move.function
      when getFunctionCode(:MIRRORMOVE)
        if target.shouldMoveAfter?(user,move)
          newMove = target.lastRegularMoveUsed
          if !newMove || !GameData::Move.get(newMove).flags[/e/]
            return changeMoveField(move,user) # Fails
          end
          newMove = PokeBattle_Move.from_pokemon_move(@battle,Pokemon::Move.new(newMove))
          if move.zMove? # Doesn't factor in Z-Move stat boost from Mirror Move
            move = PokeBattle_ZMove.from_base_move(@battle,user,newMove,GameData::PowerMove.item_from(newMove.type))
          else
            move = newMove
          end
        end
      end
      return changeMoveField(move,user)
    end
    
    # Field Move Change
    def changeMoveField(move,user)
      return move if move.zMove? # Z-Moves can't be changed by field
      newMove = nil
      case $fefieldeffect
      when 4 # Dark Crystal Cavern
        if move.id == :DIVE
          newMove = :DIG
        end
      when 7 # Volcanic Field
        if move.id == :HIGHJUMPKICK
          newMove = :JUMPKICK
        elsif move.id == :DIVE
          newMove = :DIG
        end
      when 8 # Swamp Field
        if move.id == :SURF
          newMove = :MUDDYWATER
        end
      when 10 # Corrosive Field
        if move.id == :SURF
          newMove = :MUDDYWATER
        elsif move.id == :SPIKES
          newMove = :TOXICSPIKES
        end
      when 12 # Desert Field
        if [:MUDSLAP,:MUDSPORT].include?(move.id)
          newMove = :SANDATTACK
        elsif [:MUDSHOT,:MUDBOMB].include?(move.id)
          newMove = :SCORCHINGSANDS
        end
      when 13 # Icy Cave
        if move.id == :HIGHJUMPKICK
          newMove = :JUMPKICK
        elsif move.id == :DIVE
          newMove = :DIG
        end
      when 14 # Rocky Field
        if move.id == :DIVE
          newMove = :DIG
        end
      when 16 # Volcanic Top Field
        if move.id == :FIRESPIN
          newMove = :MAGMASTORM
        end
      when 18 # Short-Circuit Field
        if move.id == :IMPRISON
          newMove = :THUNDERCAGE
        end
      when 21 # Water Surface
        if move.id == :DIG
          newMove = :DIVE
        elsif [:EARTHQUAKE,:MAGNITUDE].include?(move.id)
          newMove = :TSUNAMI
        end
      when 22 # Underwater
        if move.id == :MISTBALL
          newMove = :WATERPULSE
        end
      when 23 # Cave
        if move.id == :HIGHJUMPKICK
          newMove = :JUMPKICK
        elsif move.id == :DIVE
          newMove = :DIG
        end
      when 25 # Crystal Cavern
        if move.id == :DIVE
          newMove = :DIG
        end
      when 26 # Murkwater Surface
        if move.id == :DIG
          newMove = :DIVE
        elsif move.id == :SLUDGE
          newMove = :SLUDGEWAVE
        end
      when 27 # Mountain
        if move.id == :JUMPKICK
          newMove = :HIGHJUMPKICK
        end
      when 28 # Snowy Mountain
        if move.id == :JUMPKICK
          newMove = :HIGHJUMPKICK
        elsif move.id == :ROCKSLIDE
          newMove = :AVALANCHE
        end
      when 32 # Dragon's Den
        if move.id == :FLAMEWHEEL
          newMove = :SACREDFIRE
        elsif move.id == :FIREPLEDGE
          newMove = :BLASTBURN
        elsif move.id == :WATERPLEDGE
          newMove = :HYDROCANNON
        elsif move.id == :GRASSPLEDGE
          newMove = :FRENZYPLANT
        elsif move.id == :MIRRORSHOT
          newMove = :DOOMDESIRE
        elsif move.id == :PSYCHIC
          newMove = :PSYCHOBOOST
        elsif move.isHiddenPower?
          newMove = :JUDGMENT
        elsif @id == :OUTRAGE
          newMove = :ROAROFTIME
        elsif @id == :DUALCHOP
          newMove = :SPACIALREND
        elsif @id == :FIRESPIN
          newMove = :MAGMASTORM
        elsif @id == :VISEGRIP
          newMove = :CRUSHGRIP
        elsif @id == :ENERGYBALL
          newMove = :SEEDFLARE
        elsif @id == :PHANTOMFORCE
          newMove = :SHADOWFORCE
        elsif @id == :KARATECHOP
          newMove = :SACREDSWORD
        elsif @id == :PSYSHOCK
          newMove = :PSYSTRIKE
        elsif @id == :INCINERATE
          newMove = :SEARINGSHOT
        elsif @id == :HYPERBEAM
          newMove = :TECHNOBLAST
        elsif @id == :ROUND
          newMove = :RELICSONG
        elsif @id == :AURASPHERE
          newMove = :SECRETSWORD
        elsif @id == :ICYWIND
          newMove = :GLACIATE
        elsif @id == :WILDCHARGE
          newMove = :BOLTSTRIKE
        elsif @id == :FLAMETHROWER
          newMove = :BLUEFLARE
        elsif @id == :ICICLECRASH
          newMove = :FREEZESHOCK
        elsif @id == :FREEZEDRY
          newMove = :ICEBURN
        elsif @id == :FLAMECHARGE
          newMove = :VCREATE
        elsif @id == :BURNUP
          newMove = :FUSIONFLARE
        elsif @id == :ELECTROBALL
          newMove = :FUSIONBOLT
        elsif @id == :POWERGEM
          newMove = :DIAMONDSTORM
        elsif @id == :SCALD
          newMove = :STEAMERUPTION
        elsif @id == :EXTRASENSORY
          newMove = :HYPERSPACEHOLE
        elsif @id == :GUST
          newMove = :AEROBLAST
        elsif @id == :AIRSLASH
          newMove = :OBLIVIONWING
        elsif @id == :MAGNITUDE
          newMove = :LANDSWRATH
        elsif @id == :DAZZLINGGLEAM
          newMove = :LIGHTOFRUIN
        elsif @id == :WATERPULSE
          newMove = :ORIGINPULSE
        elsif @id == :BULLDOZE
          newMove = :PRECIPICEBLADES
        elsif @id == :BOUNCE && user.effects[PBEffects::TwoTurnAttack] == 0 # Not mid-use
          newMove = :DRAGONASCENT
        elsif @id == :DRACOMETEOR
          newMove = :COREENFORCER
        elsif @id == :FAIRYWIND
          newMove = :FLEURCANNON
        elsif @id == :PSYBEAM
          newMove = :PRISMATICLASER
        elsif @id == :ASTONISH
          newMove = :SPECTRALTHIEF
        elsif @id == :METEORMASH
          newMove = :SUNSTEELSTRIKE
        elsif @id == :SHADOWBALL
          newMove = :MOONGEISTBEAM
        elsif @id == :LAVAPLUME
          newMove = :MINDBLOWN
        elsif @id == :STOREDPOWER
          newMove = :PHOTONGEYSER
        elsif @id == :IRONHEAD
          newMove = :DOUBLEIRONBASH
        elsif @id == :DRAGONPULSE
          newMove = :DYNAMAXCANNON
        elsif @id == :SMARTSTRIKE
          newMove = :BEHEMOTHBLADE
        elsif @id == :HEAVYSLAM
          newMove = :BEHEMOTHBASH
        elsif @id == :DRAGONBREATH
          newMove = :ETERNABEAM
        elsif @id == :LASHOUT
          newMove = :WICKEDBLOW
        elsif @id == :LIQUIDATION
          newMove = :SURGINGSTRIKES
        elsif @id == :ELECTROWEB
          newMove = :THUNDERCAGE
        elsif @id == :DRAGONRAGE
          newMove = :DRAGONENERGY
        elsif @id == :CONFUSION
          newMove = :FREEZINGGLARE
        elsif @id == :SNARL
          newMove = :FIERYWRATH
        elsif @id == :JUMPKICK
          newMove = :THUNDEROUSKICK
        elsif @id == :ICICLESPEAR
          newMove = :GLACIALLANCE
        elsif @id == :OMINOUSWIND
          newMove = :ASTRALBARRAGE
        elsif @id == :DRILLRUN
          newMove = :THOUSANDARROWS
        elsif @id == :EARTHQUAKE
          newMove = :THOUSANDWAVES
        end
      when 37 # Psychic Terrain
        if @id == :HEADBUTT
          newMove = :ZENHEADBUTT
        end
      when 40 # Haunted Field
        if @id == :GUST
          newMove = :OMINOUSWIND
        end
      when 41 # Corrupted Cave
        if move.id == :HIGHJUMPKICK
          newMove = :JUMPKICK
        elsif move.id == :DIVE
          newMove = :DIG
        elsif [:SURF,:MUDDYWATER,:TSUNAMI].include?(move.id)
          newMove = :SLUDGEWAVE
        end
      when 44 # Indoors
        if move.id == :HIGHJUMPKICK
          newMove = :JUMPKICK
        end
      end
      if !newMove.nil?
        newMove = PokeBattle_Move.from_pokemon_move(@battle,Pokemon::Move.new(newMove))
        move = newMove
      end
      return move
    end
    
    # Returns a multiplier based on the input multiplier (>1) that is higher the more
    # setup capability the given user has
    def runSetupMoves(user,multiplier)
      user.eachOpposing do |b|
        if user.near?(b)
          return 1 if b.hasActiveAbility?(:UNAWARE)
          return 1 if b.hasKnownMoveFunction?([:SPECTRALTHIEF,:CLEARSMOG,:HEARTSWAP,
                      :PSYCHUP,:PUNISHMENT,:TOPSYTURVY])
        end
        return 1 if b.hasKnownMoveFunction?(:HAZE)
      end
      finalMult = 1
      if user.hasKnownMoveFunction?(:ACUPRESSURE)
        finalMult *= 1 + (multiplier-1)*0.4
      end
      if user.hasActiveAbility?(:SPEEDBOOST)
        finalmult *= 1 + (multiplier-1)*0.7
      end
      if user.hasActiveAbility?(:MOODY)
        finalmult *= 1 + (multiplier-1)*0.4
      end
      statIncrease = [0,0,0,0,0,0,0]
      if !user.hasActiveAbility?(:CONTRARY)
        for m in user.moves
          next if m.pp == 0 || !m.is_a?(PokeBattle_StatUpMove) && !m.is_a?(PokeBattle_Move_035) # Shell Smash
          next if !(m.addlEffect == 0 || m.addlEffect >= 50) # Don't consider unlikely stat up
          echo("\n[AI - #{Time.now - $time}] Counting #{m.name} as a setup move.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          statUp = m.getStatUp
          for i in 0...statUp.length/2
            case statUp[i*2]
            when :ATTACK
              statIncrease[0] += statUp[i*2 + 1] if user.pbCanRaiseStatStage?(:ATTACK,user)
            when :DEFENSE
              statIncrease[1] += statUp[i*2 + 1] if user.pbCanRaiseStatStage?(:DEFENSE,user)
            when :SPECIAL_ATTACK
              statIncrease[2] += statUp[i*2 + 1] if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user)
            when :SPECIAL_DEFENSE
              statIncrease[3] += statUp[i*2 + 1] if user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user)
            when :SPEED
              statIncrease[4] += statUp[i*2 + 1] if user.pbCanRaiseStatStage?(:SPEED,user)
            when :ACCURACY
              statIncrease[5] += statUp[i*2 + 1] if user.pbCanRaiseStatStage?(:ACCURACY,user)
            when :EVASION
              statIncrease[6] += statUp[i*2 + 1] if user.pbCanRaiseStatStage?(:EVASION,user)
            end
          end
        end
      else
        for m in user.moves
          next if m.pp == 0 || !m.is_a?(PokeBattle_StatDownMove) && !m.is_a?(PokeBattle_Move_035) # Shell Smash
          next if !(m.addlEffect == 0 || m.addlEffect >= 50) # Don't consider unlikely stat up
          echo("\n[AI - #{Time.now - $time}] Counting #{m.name} as a setup move.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          statDown = m.getStatDown
          for i in 0...statDown.length/2
            case statDown[i*2]
            when :ATTACK
              statIncrease[0] += statDown[i*2 + 1] if user.pbCanRaiseStatStage?(:ATTACK,user)
            when :DEFENSE
              statIncrease[1] += statDown[i*2 + 1] if user.pbCanRaiseStatStage?(:DEFENSE,user)
            when :SPECIAL_ATTACK
              statIncrease[2] += statDown[i*2 + 1] if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user)
            when :SPECIAL_DEFENSE
              statIncrease[3] += statDown[i*2 + 1] if user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user)
            when :SPEED
              statIncrease[4] += statDown[i*2 + 1] if user.pbCanRaiseStatStage?(:SPEED,user)
            when :ACCURACY
              statIncrease[5] += statDown[i*2 + 1] if user.pbCanRaiseStatStage?(:ACCURACY,user)
            when :EVASION
              statIncrease[6] += statDown[i*2 + 1] if user.pbCanRaiseStatStage?(:EVASION,user)
            end
          end
        end
      end
      if user.hasActiveAbility?(:SIMPLE)
        for i in 0...statIncrease.length
          statIncrease[i] *= 2
        end
      end
      i = 0
      GameData::Stat.each_battle { |s| 
        statIncrease[i] = [statIncrease[i], 6-user.stages[s.id]].min # Not to go above +6
        i += 1
      }
      if statIncrease[0] > 0 && user.hasPhysicalMove? # Attack
        avgDef = 0
        user.eachNearOpposing do |b|
          avgDef += b.pbDefense(user.hasMoldBreaker?)
        end
        avgDef /= user.numNearOpposing
        # Better to use setup moves when stat is low relative to opponent's
        mult = 1 + statIncrease[0]*(multiplier-1)*avgDef/user.pbAttack(user.hasMoldBreaker?)
        finalMult *= mult
        echo("\n[AI - #{Time.now - $time}] Due to #{user.pbThis(true)}'s potential Attack increase of +#{statIncrease[0]}, the final multiplier increases x#{mult}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if statIncrease[1] > 0 # Defense
        avgAtk = 0
        user.eachNearOpposing do |b|
          avgAtk += b.pbAttack(b.hasMoldBreaker?) if b.hasExpectedPhysicalMove?
        end
        avgAtk /= user.numNearOpposing
        # Better to use setup moves when stat is low relative to opponent's
        mult = 1 + 0.7*statIncrease[1]*(multiplier-1)*avgAtk/user.pbDefense(false) # Some might moldbreak while others not, so just assume not
        finalMult *= mult
        echo("\n[AI - #{Time.now - $time}] Due to #{user.pbThis(true)}'s potential Defense increase of +#{statIncrease[1]}, the final multiplier increases x#{mult}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if statIncrease[2] > 0 && user.hasSpecialMove? # Sp. Atk
        avgSpDef = 0
        user.eachNearOpposing do |b|
          avgSpDef += b.pbSpDef(user.hasMoldBreaker?)
        end
        avgSpDef /= user.numNearOpposing
        # Better to use setup moves when stat is low relative to opponent's
        mult = 1 + statIncrease[2]*(multiplier-1)*avgSpDef/user.pbSpAtk(user.hasMoldBreaker?)
        finalMult *= mult
        echo("\n[AI - #{Time.now - $time}] Due to #{user.pbThis(true)}'s potential Sp. Atk increase of +#{statIncrease[2]}, the final multiplier increases x#{mult}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if statIncrease[3] > 0 # Sp. Def
        avgSpAtk = 0
        user.eachNearOpposing do |b|
          avgSpAtk += b.pbSpAtk(b.hasMoldBreaker?) if b.hasExpectedSpecialMove?
        end
        avgSpAtk /= user.numNearOpposing
        # Better to use setup moves when stat is low relative to opponent's
        mult = 1 + 0.7*statIncrease[3]*(multiplier-1)*avgSpAtk/user.pbSpDef(false) # Some might moldbreak while others not, so just assume not
        finalMult *= mult
        echo("\n[AI - #{Time.now - $time}] Due to #{user.pbThis(true)}'s potential Sp. Def increase of +#{statIncrease[3]}, the final multiplier increases x#{mult}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if statIncrease[4] > 0 && !user.fasterThanAllOpposing? # Speed
        avgSpeed = 0
        user.eachNearOpposing do |b|
          avgSpeed += b.pbSpeed
        end
        avgSpeed /= user.numNearOpposing
        # Better to use setup moves when stat is low relative to opponent's
        mult = 1 + statIncrease[4]*(multiplier-1)*avgSpeed/user.pbSpeed
        finalMult *= mult
        echo("\n[AI - #{Time.now - $time}] Due to #{user.pbThis(true)}'s potential Speed increase of +#{statIncrease[4]}, the final multiplier increases x#{mult}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if statIncrease[5] > 0 && !user.hasEvasionCounter? # Accuracy
        # Only takes into account opponents with increases in Evasion
        avgEva = 0.0
        user.eachNearOpposing do |b|
          avgEva += b.stages[:EVASION] + 6
        end
        avgEva /= user.numNearOpposing
        # Better to use setup moves when stat is low relative to opponent's
        mult = 1 + 0.5*statIncrease[5]*(multiplier-1)*avgEva/(user.stages[:ACCURACY]+6)
        finalMult *= mult
        echo("\n[AI - #{Time.now - $time}] Due to #{user.pbThis(true)}'s potential Accuracy increase of +#{statIncrease[5]}, the final multiplier increases x#{mult}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if statIncrease[6] > 0 # Evasion
        avgAcc = 0.0
        evaCounter = false
        user.eachNearOpposing do |b|
          if b.hasEvasionCounter?(user)
            evaCounter = true
            break
          end
          avgAcc += b.stages[:ACCURACY] + 6
        end
        avgAcc /= user.numNearOpposing
        if user.stages[:EVASION] + 6 < avgAcc || evaCounter # Don't bother setting up Evasion if opponent has counter
          mult = 1
        else
          # Better to use Evasion setup moves when it's low
          mult = 1 + 0.5*statIncrease[6]*(multiplier-1)*avgAcc/(user.stages[:EVASION]+6)
        end
        finalMult *= mult
        echo("\n[AI - #{Time.now - $time}] Due to #{user.pbThis(true)}'s potential Evasion increase of +#{statIncrease[6]}, the final multiplier increases x#{mult}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      # General setup things
      if user.hasKnownMoveFunction?(:BELLYDRUM) && user.hasPhysicalMove? && user.pbCanRaiseStatStage?(:ATTACK,user)
        avgDef = 0
        user.eachNearOpposing do |b|
          avgDef += b.pbDefense(user.hasMoldBreaker?)
        end
        avgDef /= user.numNearOpposing
        # Better to use setup moves when stat is low relative to opponent's
        mult = 1 + 3*(multiplier-1)*avgDef/user.pbAttack(user.hasMoldBreaker?)
        finalMult *= mult
        echo("\n[AI - #{Time.now - $time}] Due to #{user.pbThis(true)} having Belly Drum, the final multiplier increases x#{mult}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if user.hasKnownMoveFunction?(:FOCUSENERGY) && user.effects[PBEffects::FocusEnergy] == 0
        finalMult *= multiplier
        echo("\n[AI - #{Time.now - $time}] Due to #{user.pbThis(true)} having Focus Energy, the final multiplier increases x#{multiplier}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if user.hasKnownMoveFunction?(:VICTORYDANCE) && !user.effects[PBEffects::VictoryDance]
        finalMult *= multiplier
        echo("\n[AI - #{Time.now - $time}] Due to #{user.pbThis(true)} having Victory Dance, the final multiplier increases x#{multiplier}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if user.hasKnownMoveFunction?(:SUBSTITUTE) && user.effects[PBEffects::Substitute] == 0
        finalMult *= multiplier
        echo("\n[AI - #{Time.now - $time}] Due to #{user.pbThis(true)} having Substitute, the final multiplier increases x#{multiplier}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      echo("\n[AI - #{Time.now - $time}] Due to #{user.pbThis(true)} having #{user.numNearOpposing} nearby opponents, the final multiplier decreases from #{finalMult} to #{1+(finalMult-1)/user.numNearOpposing}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      return 1 + (finalMult-1)/user.numNearOpposing # Not as good to set up when multiple opponents
    end
    
    # Returns a score that reflects additional effect chance
    def effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
      if effectChance > 0 # Move has an additional effect
        addlEffectChance = additionalEffectChance(callMove,user,target) / 100.0
      else # move doesn't have an additional effect, meaning effect always occurs
        addlEffectChance = 1.0
      end 
      if effectChance >= 0 # Occurs as long as landing a hit
        if target
          addlEffectChance *= pbRoughAccuracy(callMove,realMove,user,target) / 100.0
        end # Always hits if there's no target
        # Accounts for number of hits (but only treats as if the effect can occur once at most per execution)
        addlEffectChance = 1 - (1 - addlEffectChance)**getNumHits(callMove,user,target)
      elsif effectChance == -1 # Occurs only when missing (Jump Kick)
        addlEffectChance *= 1 - pbRoughAccuracy(callMove,realMove,user,target) / 100.0
        # Accounts for number of hits (but only treats as if the effect can occur once at most per execution)
        addlEffectChance = 1 - (1 - addlEffectChance)**getNumHits(callMove,user,target)
      end # Don't call this method if effect occurs regardless of hit or miss (or input something less than -1)
      return effectScore * addlEffectChance
    end
    
    # Returns a score corresponding to how good it would be to have the given battler's
    # end-of-round effects activate based on the given user's relationship to it (if
    # user opposes battler, good effects return a negative score and vice versa).
    # Used to see how much is gained by having a battler get an "extra" round of effects
    # (usually induced by skipping battler's turn). Assumes that it's the current
    # round for determining what should happen.
    def endOfRoundScore(user,battler)
      score = 0
      # Trick Room to effectively see expected HP at the end of the round
      fakeMove = alwaysLastMove
      battlerERHP = battler.residualHP(battler.hp)
      score = 100*battlerERHP/battler.hp - 100
      if score == -100 # Battler knocked out by end of round effects (so other effects don't matter)
        return (user.opposes?(battler)) ? 100 : -100
      end
      score *= -1 if user.opposes?(battler)
      case $fefieldeffect
      when 1 # Electric Terrain
        if battler.grounded? && !battler.hasActiveItem?(:HEAVYDUTYBOOTS) && battler.turnCount > 0 &&
           !battler.frozen?
          if battler.hasActiveAbility?([:STATIC,:HUSTLE,:VITALSPIRIT,:MOTORDRIVE,:RATTLED,:TERAVOLT])
            score -= pbGetMoveScoreFunctionCode("TargetSpeedUp",fakeMove,fakeMove,
                     user,battler,0,[],[],0,2)
          else
            score -= pbGetMoveScoreFunctionCode("TargetSpeedUp",fakeMove,fakeMove,
                     user,battler,0,[],[],0,1)
          end
        end
      when 2 # Grassy Terrain
        if battler.hasActiveAbility?(:NATURALCURE)
          score -= pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
        end
      when 5 # Chess Board
        if battler.hasActiveAbility?(:OBLIVIOUS) && battler.turnCount > 0
          score -= pbGetMoveScoreFunctionCode("TargetSpeedDown",fakeMove,fakeMove,
                   user,battler,0,[],[],0,1)
        end
      when 7 # Volcanic Field
        if battler.hasActiveAbility?(:FLASHFIRE)
          score -= pbGetMoveScoreFunctionCode("TargetFlashFire",fakeMove,fakeMove,user,battler,0)
        end
      when 8 # Swamp Field
        if battler.grounded?
          if battler.turnCount > 0 && !battler.hasActiveAbility?([:QUICKFEET,:SUCTIONCUPS,:WATERVEIL,:SWIFTSWIM]) &&
             @battle.pbWeather != :Sun && !battler.hasActiveItem?(:HEAVYDUTYBOOTS)
            if battler.pbCanLowerStatStage?(:SPEED)
              numStages = 1
              if battler.hasActiveAbility?([:BATTLEARMOR,:TANGLEDFEET,:HEAVYMETAL])
                numStages += 1
              end
              if battler.effects[PBEffects::TrappingMove] == :SANDTOMB
                numStages += 1
              end
              if battler.asleep?
                numStages += 1
              end
              score -= pbGetMoveScoreFunctionCode("TargetSpeedDown",fakeMove,fakeMove,
                       user,battler,0,[],[],0,numStages)
            end
          end
          score -= pbGetMoveScoreFunctionCode("TargetBurnCure",fakeMove,fakeMove,user,battler,0)
          if battler.hasActiveAbility?(:WATERCOMPACTION)
            score -= pbGetMoveScoreFunctionCode("targetDefenseUp",fakeMove,fakeMove,
                     user,battler,0,[],[],0,2)
          end
        end
      when 9 # Rainbow Field
        if battler.hasActiveAbility?([:CLOUDNINE,:PASTELVEIL])
          score -= (user.opposes?(battler)) ? 5 : -5
        end
      when 11 # Corrosive Mist Field
        if !battler.hasActiveAbility?([:LIQUIDOOZE,:AIRLOCK,:FILTER])
          if battler.hasActiveAbility?([:WATERVEIL,:WATERABSORB,:RAINDISH,:WATERBUBBLE])
            score -= pbGetMoveScoreFunctionCode(getFunctionCode(:TOXIC),fakeMove,fakeMove,user,battler,0)
          else
            score -= pbGetMoveScoreFunctionCode(getFunctionCode(:POISONGAS),fakeMove,fakeMove,user,battler,0)
          end
        end
        if battler.hasActiveAbility?([:MAGMAARMOR,:FLAMEBODY,:TURBOBLAZE,:STEAMENGINE,:FLASHFIRE])
          score -= pbGetMoveScoreFunctionCode("TargetFlashFire",fakeMove,fakeMove,user,battler,0)
        end
        if pbCheckGlobalAbility(:NEUTRALIZINGGAS) && !battler.hasActiveAbility?(:NEUTRALIZINGGAS)
          score -= pbGetMoveScoreFunctionCode("TargetAccuracyDown",fakeMove,fakeMove,
                   user,battler,0,[],[],0,1)
        end
      when 12 # Desert Field
        if battler.hasActiveAbility?([:HUSTLE,:OVERCOAT,:FURCOAT])
          score -= pbGetMoveScoreFunctionCode("TargetSpeedDown",fakeMove,fakeMove,
                   user,battler,0,[],[],0,1)
        end
      when 15 # Forest Field
        if battler.hasActiveAbility?(:NATURALCURE)
          score -= pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
        end
      when 16 # Volcano Top Field
        if volTopEruption?
          if battler.hasActiveAbility?(:MAGMAARMOR)
            score -= pbGetMoveScoreFunctionCode("TargetDefenseUp",fakeMove,fakeMove,
                     user,battler,0,[],[],0,1)
            score -= pbGetMoveScoreFunctionCode("TargetSpDefUp",fakeMove,fakeMove,
                     user,battler,0,[],[],0,1)
          end
          if battler.hasActiveAbility?([:FLAREBOOST,:TURBOBLAZE])
            score -= pbGetMoveScoreFunctionCode("TargetSpAtkUp",fakeMove,fakeMove,
                     user,battler,0,[],[],0,1)
          end
          if battler.hasActiveAbility?(:STEAMENGINE)
            score -= pbGetMoveScoreFunctionCode("TargetSpeedUp",fakeMove,fakeMove,
                     user,battler,0,[],[],0,1)
          end
          if battler.hasActiveAbility?(:FLASHFIRE)
            score -= pbGetMoveScoreFunctionCode("TargetFlashFire",fakeMove,fakeMove,user,battler,0)
          end
          if !battler.hasActiveAbility?(:SOUNDPROOF)
            score -= pbGetMoveScoreFunctionCode("TargetSleepCure",fakeMove,fakeMove,user,battler,0)
          end
          # Leech Seed removal
          # Spikes removal
          # Toxic Spikes removal
          # Stealth Rock removal
          # Sticky Web removal
        end
      when 18 # Short-Circuit Field
        if battler.affectedByShortCircuit?
          if battler.hasActiveAbility?([:WATERVEIL,:WATERBUBBLE])
            score -= pbGetMoveScoreFunctionCode(getFunctionCode(:THUNDERWAVE),fakeMove,fakeMove,user,battler,0)
          else # 25% chance to paralyze
            score -= 0.25*pbGetMoveScoreFunctionCode(getFunctionCode(:THUNDERWAVE),fakeMove,fakeMove,user,battler,0)
          end
        end
      when 20 # Ashen Beach
        if @battle.pbCheckGlobalAbility(:WHITESMOKE) && !battler.hasActiveAbility?(:WHITESMOKE)
          score -= pbGetMoveScoreFunctionCode("TargetAccuracyDown",fakeMove,fakeMove,
                   user,battler,0,[],[],0,1)
        end
        if @battle.pbCheckGlobalAbility(:NEUTRALIZINGGAS) && !battler.hasActiveAbility?(:NEUTRALIZINGGAS)
          score -= pbGetMoveScoreFunctionCode("TargetAccuracyDown",fakeMove,fakeMove,
                   user,battler,0,[],[],0,1)
        end
      when 21 # Water Surface
        if battler.grounded? && battler.hasActiveAbility?(:WATERCOMPACTION)
          score -= pbGetMoveScoreFunctionCode("TargetDefenseUp",fakeMove,fakeMove,
                   user,battler,0,[],[],0,2)
        end
      when 22 # Underwater
        if b.hasActiveAbility?(:WATERCOMPACTION)
          score -= pbGetMoveScoreFunctionCode("TargetDefenseUp",fakeMove,fakeMove,
                   user,battler,0,[],[],0,2)
        end
      when 26 # Murkwater Surface
        if battler.affectedByMurkwaterSurface? && battler.turnCount > 0
          if battler.pbCanLowerStatStage?(:SPECIAL_DEFENSE)
            numStages = 1
            if battler.hasActiveAbility?([:FLAMEBODY,:MAGMAARMOR,:DRYSKIN,:WATERABSORB,:FLOWERVEIL,:FLOWERGIFT])
              numStages += 1
            end
            if battler.effects[PBEffects::TrappingMove] == :WHIRLPOOL
              numStages += 1
            end
            if battler.effects[PBEffects::TwoTurnAttack] == :DIVE
              numStages += 1
            end
            score -= pbGetMoveScoreFunctionCode("TargetSpDefDown",fakeMove,fakeMove,
                     user,battler,0,[],[],0,numStages)
          end
        end
        if battler.grounded? && battler.hasActiveAbility?(:WATERCOMPACTION)
          score -= pbGetMoveScoreFunctionCode("TargetDefenseUp",fakeMove,fakeMove,
                   user,battler,0,[],[],0,2)
        end
      when 31 # Fairy Tale Field
        if battler.hasActiveAbility?(:NATURALCURE)
          score -= pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
        end
      when 33 # Flower Garden Field
        if $fecounter >= 2 && battler.hasActiveAbility?(:NATURALCURE)
          score -= pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
        end
      when 42 # Bewitched Woods
        if battler.hasActiveAbility?(:NATURALCURE)
          score -= pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
        end
      when 43 # Sky Field
        if @battle.pbCheckGlobalAbility(:CLOUDNINE) && !battler.hasActiveAbility?(:CLOUDNINE)
          score -= pbGetMoveScoreFunctionCode("TargetAccuracyDown",fakeMove,fakeMove,
                   user,battler,0,[],[],0,1)
        end
      when 46 # Subzero Field
        if !battler.hasActiveAbility?([:FLAMEBODY,:FLASHFIRE,:FURCOAT,:OVERCOAT]) && 
           !battler.pbHasType?(:FIRE) && !battler.hasActiveItem?([:CHOICESCARF,:SILKSCARF,
           :HEAVYDUTYBOOTS])
          if battler.hasActiveAbility?(:WATERVEIL)
            score -= 0.5*pbGetMoveScoreFunctionCode(getFunctionCode(:ICEBEAM),fakeMove,fakeMove,user,battler,0)
          else
            score -= 0.25*pbGetMoveScoreFunctionCode(getFunctionCode(:ICEBEAM),fakeMove,fakeMove,user,battler,0)
          end
        end
      when 48 # Beach
        if (!battler.pbHasAnyStatus? || battler.asleep?) && battler.turnCount > 0
          if battler.asleep?
            score -= pbGetMoveScoreFunctionCode("TargetDefenseUp",fakeMove,fakeMove,
                     user,battler,0,[],[],0,2)
            score -= pbGetMoveScoreFunctionCode("TargetSpDefUp",fakeMove,fakeMove,
                     user,battler,0,[],[],0,2)
          else
            score -= pbGetMoveScoreFunctionCode("TargetDefenseUp",fakeMove,fakeMove,
                     user,battler,0,[],[],0,1)
            score -= pbGetMoveScoreFunctionCode("TargetSpDefUp",fakeMove,fakeMove,
                     user,battler,0,[],[],0,1)
          end
        end
      end
      # To Do - Wasteland Entry Hazards
      if $fefieldeffect != 38
        # Check if battler will heal allied status
        if battler.hasActiveAbility?(:HEALER)
          battler.eachAlly do |a|
            # Treat as if user is curing status to allow for proper move memory
            if [3,9,29].include?($fefieldeffect)
              score -= pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,a,0)
            else
              score -= 0.3*pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,a,0)
            end
          end
        end
        # Check if allied Healer will heal battler's status
        battler.eachAlly do |a|
          next if !a.hasActiveAbility?(:HEALER)
          # Treat as if user is curing status to allow for proper move memory
          if [3,9,29].include?($fefieldeffect)
            score -= pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
          else
            score -= 0.3*pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
          end
          break # Only calculate as if one ally is curing
        end
      end
      if battler.status != :NONE
        if battler.hasActiveAbility?(:HYDRATION) && ([:Rain, :HeavyRain].include?(@battle.pbWeather) &&
           !battler.hasUtilityUmbrella? || [8,21,26].include?($fefieldeffect) && battler.grounded? ||
           $fefieldeffect == 22) && $fefieldeffect != 16 || battler.hasActiveAbility?(:WATERVEIL) &&
           ($fefieldeffect == 22 || $fefieldeffect == 21 && battler.grounded?)
          score -= pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
        end
        if battler.hasActiveAbility?(:SHEDSKIN)
          if [12,49].include?($fefieldeffect)
            score -= 0.6*pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
          else
            score -= 0.3*pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
          end
        end
      end
      if battler.effects[PBEffects::Octolock]
        score -= pbGetMoveScoreFunctionCode("TargetDefenseDown",fakeMove,fakeMove,
                 user,battler,0,[],[],0,1)
        score -= pbGetMoveScoreFunctionCode("TargetSpDefDown",fakeMove,fakeMove,
                 user,battler,0,[],[],0,1)
      end
      if battler.effects[PBEffects::Trapping] > 1 && $fefieldeffect == 20 && battler.effects[PBEffects::TrappingMove] == :SANDTOMB
        score -= pbGetMoveScoreFunctionCode("TargetAccuracyDown",fakeMove,fakeMove,
                 user,battler,0,[],[],0,1)
      end
      # Effects getting closer to wearing off
      if battler.effects[PBEffects::Taunt] > 0 
        score -= (user.opposes?(battler)) ? 5 : -5
      end
      if battler.effects[PBEffects::Encore] > 0
        score -= (user.opposes?(battler)) ? 5 : -5
      end
      if battler.effects[PBEffects::Disable] > 0
        score -= (user.opposes?(battler)) ? 5 : -5
      end
      if battler.effects[PBEffects::MagnetRise] > 0
        score -= (user.opposes?(battler)) ? 5 : -5
      end
      if battler.effects[PBEffects::Telekinesis] > 0
        score -= (user.opposes?(battler)) ? 5 : -5
      end
      if battler.effects[PBEffects::HealBlock] > 0
        score -= (user.opposes?(battler)) ? 5 : -5
      end
      if battler.effects[PBEffects::Embargo] > 0
        score -= (user.opposes?(battler)) ? 5 : -5
      end
      if battler.effects[PBEffects::Yawn] > 0
        score -= (user.opposes?(battler)) ? -25 : 25
      end
      if battler.effects[PBEffects::PerishSong] > 0
        score -= (user.opposes?(battler)) ? -20 : 20
      end
      if battler.pbOwnSide.effects[PBEffects::Reflect] > 0
        score -= (user.opposes?(battler)) ? 10 : -10
      end
      if battler.pbOwnSide.effects[PBEffects::LightScreen] > 0
        score -= (user.opposes?(battler)) ? 10 : -10
      end
      if battler.pbOwnSide.effects[PBEffects::Safeguard] > 0
        score -= (user.opposes?(battler)) ? 5 : -5
      end
      if battler.pbOwnSide.effects[PBEffects::Mist] > 0
        score -= (user.opposes?(battler)) ? 5 : -5
      end
      if battler.pbOwnSide.effects[PBEffects::Tailwind] > 0
        score -= (user.opposes?(battler)) ? 10 : -10
      end
      if battler.pbOwnSide.effects[PBEffects::LuckyChant] > 0
        score -= (user.opposes?(battler)) ? 5 : -5
      end
      if battler.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        score -= (user.opposes?(battler)) ? 15 : -15
      end
      # Trick Room
      # Gravity
      # Water Sport
      # Mud Sport
      # Wonder Room
      # Magic Room
      if battler.effects[PBEffects::Uproar] > 0
        score -= (user.opposes?(battler)) ? 5 : -5
      end
      if battler.effects[PBEffects::SlowStart] > 0
        score -= (user.opposes?(battler)) ? 10 : -10
      end
      if battler.hasActiveAbility?(:MOODY) # Perhaps too basic
        score -= (user.opposes?(battler)) ? 10 : -10
      end
      if battler.hasActiveAbility?(:SPEEDBOOST) && battler.turnCount>0 && $fefieldeffect != 44 &&
         !(!battler.pbHasType?(:WATER) && ($fefieldeffect == 22 || [21,26].include?($fefieldeffect) &&
         battler.grounded?))
        score -= pbGetMoveScoreFunctionCode("TargetSpeedUp",fakeMove,fakeMove,
                 user,battler,0,[],[],0,1)
      end
      if $fefieldeffect == 42
        eachNearAlly do |a|
          if a.hasActiveAbility?(:MEDIC)
            score -= pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
            break
          end
        end
      end
      if battler.pbHasType?(:GRASS) && ($fefieldeffect == 2 || $fefieldeffect == 33 && 
         $fecounter >= 3) && battler.pbHasAnyStatus?
        @battle.eachBattler do |b|
          if b.hasActiveAbility?(:SOOTHINGAROMA)
            score -= pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
            break
          end
        end
      end
      if battler.pbHasAnyStatus? && ![10,11,41].include?($fefieldeffect) && !($fefieldeffect == 26 &&
         battler.grounded?)
        statusCured = false
        battler.eachNearAlly do |a|
          if a.hasActiveAbility?(:SEEDREVITALIZATION) && !a.effects[PBEffects::SeedRevitalization]
            statusCured = true
            score -= pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
            if $fefieldeffect == 33
              score -= pbGetMoveScoreFunctionCode("RaiseFlowerGarden",fakeMove,fakeMove,user,battler,0)
            elsif $fefieldeffect == 42
              score -= (user.opposes?(battler)) ? 10 : -10 # Raise random stat
            end
            break
          end
        end
        if !statusCured && [2,15,47].include?($fefieldeffect) && battler.hasActiveAbility?(:SEEDREVITALIZATION)
          score -= pbGetMoveScoreFunctionCode("TargetStatusCure",fakeMove,fakeMove,user,battler,0)
        end
      end
      battler.eachNearOpposing do |o|
        if o.hasActiveAbility?(:ALPHABETIZATION) && o.checkAlphabetizationForm(11)
          score -= pbGetMoveScoreFunctionCode(getFunctionCode(:ATTRACT),fakeMove,fakeMove,user,battler,0)
        end
      end
      if battler.hasActiveAbility?(:ALPHABETIZATION) && battler.checkAlphabetizationForm(16) &&
         battler.turnCount > 0
        score -= pbGetMoveScoreFunctionCode("TargetEvasionUp",fakeMove,fakeMove,user,battler,0)
      end
      if battler.hasActiveAbility?(:CHARGINGSACS) && battler.turnCount>0
        score -= 0.5*pbGetMoveScoreFunctionCode("TargetAttackUp",fakeMove,fakeMove,user,battler,0)
        score -= 0.5*pbGetMoveScoreFunctionCode("TargetSpAtkUp",fakeMove,fakeMove,user,battler,0)
      end
      if battler.hasActiveItem?(:FLAMEORB)
        score -= pbGetMoveScoreFunctionCode(getFunctionCode(:WILLOWISP),fakeMove,fakeMove,user,battler,0)
      end
      if battler.hasActiveItem?(:TOXICORB)
        score -= pbGetMoveScoreFunctionCode(getFunctionCode(:TOXIC),fakeMove,fakeMove,user,battler,0)
      end
      # Harvest
      # Pickup
      return score
    end
    
    # Returns whether there's an expected eruption on the Volcanic Top Field
    def volTopEruption?
      return false if @battle.dampBattler?
      # Arbitrary user because Trick Room always goes last
      for hit in expectedHitsBeforeAction(@user,alwaysLastMove)
        if [:BULLDOZE,:EARTHQUAKE,:MAGNITUDE,:ERUPTION,:PRECIPICEBLADES,:LAVAPLUME,
           :FISSURE,:TECTONICRAGE].include?(hit.id)
          return true
        end
      end
      return false
    end
    
    # Returns a score multiplier corresponding to the given battler's stat changes and the given base multiplier
    def statChangeMult(battler,multiplier,defensiveOnly=false,offensiveOnly=false)
      statSum = 0
      GameData::Stat.each_battle { |s|
        next if defensiveOnly && [:ATTACK,:SPECIAL_ATTACK,:ACCURACY,:SPEED].include?(s.id)
        next if offensiveOnly && [:DEFENSE,:SPECIAL_DEFENSE,:EVASION].include?(s.id)
        statSum += battler.stages[s.id]
      }
      ret = 1.0
      cap = (statSum > 0) ? statSum : -1*statSum
      # Weigh final multiplier so first few stat changes count for more
      for i in 0...cap
        ret += (multiplier-1) * 2.0 / (1 + (Math::E)**(0.5*i))
      end
      return (statSum > 0) ? ret : 1.0 / ret
    end
    
    def getNumHits(move,user,target)
      case move.function
      when getFunctionCode(:DOUBLEKICK),getFunctionCode(:TWINEEDLE),getFunctionCode(:DOUBLEIRONBASH)
        return 2
      when getFunctionCode(:TRIPLEKICK)
        return 3
      when getFunctionCode(:FURYATTACK)
        if user.hasActiveAbility?(:SKILLLINK)
          return 5
        elsif user.hasActiveAbility?(:BATTLEBOND) && move.id == :WATERSHURIKEN
          return 3
        else
          return 19.0/6
        end
      when getFunctionCode(:BEATUP),getFunctionCode(:CHAINLIGHTNING)
        mult = 0
        @battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,_i|
          mult += 1 if pkmn && pkmn.able? && pkmn.status == :NONE
        end
        return mult
      when getFunctionCode(:DRAGONFLEET)
        mult = 0
        @battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,_i|
          mult += 1 if pkmn && pkmn.able? && pkmn.status == :NONE && pkmn.hasType?(:DRAGON)
        end
       return mult
      when getFunctionCode(:DRAGONDARTS)
        if @battle.pbSideBattlerCount(target) == 1
          return 2
        else
          return 1
        end
      when getFunctionCode(:SURGINGSTRIKES)
        return 3
      else
        if user.hasActiveAbility?(:PARENTALBOND) && move.pbTarget(user).num_targets == 1
          # Doesn't affect multi-hit moves or spread moves
          return 2
        else
          return 1
        end
      end
    end
    
    # Returns whether it's worth considering certain effect done to the target
    # Don't call this method if the effect occurs on the user because that will occur irrelevant of target's state
    def checkEffect?(callMove,realMove,user,target,damage)
      # Don't target mons that will be knocked out by the end of the round
      return target.hp - damage > 0
    end
    
    # Returns a Pokebattle_Move object for a move (Trick Room) that will always go last
    # Used for end-of-round calculations
    def alwaysLastMove
      return PokeBattle_Move.from_pokemon_move(@battle,Pokemon::Move.new(:TRICKROOM))
    end
    
    # Returns an array containing the battlers that will redirect given user's move against the given target
    def redirectionCheck(user,move)
      ret = []
      types = move.pbCalcTypes(user)
      if types.include?(:ELECTRIC) && ![15,22,42,47].include?($fefieldeffect)
        user.eachNearBattler do |b|
          if b.hasActiveAbility?(:LIGHTNINGROD)
            ret.push(b)
          end
        end
      end
      if types.include?(:WATER) && $fefieldeffect != 22
        user.eachNearBattler do |b|
          if b.hasActiveAbility?(:STORMDRAIN)
            ret.push(b)
          end
        end
      end
      if types.include?(:GROUND)
        user.eachNearBattler do |b|
          if b.hasActiveAbility?(:BEARDEDMAGNETISM)
            ret.push(b)
          end
        end
      end
      return ret
    end
  end