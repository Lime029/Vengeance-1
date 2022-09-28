class PokeBattle_Battler
    #=============================================================================
    # Effect per hit
    #=============================================================================
    def pbEffectsOnMakingHit(move,user,target)
      # Target's ability
      if target.damageState.calcDamage>0 && !target.damageState.substitute
        # Damaging moves
        oldHP = user.hp
        #BattleHandlers.triggerTargetAbilityOnHit(target.ability,user,target,move,@battle)
        if !user.fainted?
          # Effect on user
          if move.pbContactMove?(user)
            # Contact-Only
            if $fefieldeffect == 16
              if user.hasActiveAbility?(:KLUTZ)
                for i in [target,user]
                  if @battle.pbRandom(4) == 0 # Falls in
                    if i.fallsIntoVolcano?
                      if i == target
                        message = _INTL("{1} accidentally pushed {2} into the volcano!",user.pbThis,i.pbThis(true))
                      else
                        message = _INTL("{1} accidentally fell into the volcano!",i.pbThis)
                      end
                      i.pbInflictTypeScalingFixedDamage(:FIRE,i.totalhp/2,message)
                    end
                  end
                end
              elsif target.damageState.critical && ([:HEADBUTT,:TAKEDOWN,:DOUBLEEDGE,
                    :SEISMICTOSS,:VITALTHROW,:KNOCKOFF,:TACKLE,:VOLTTACKLE,:FORCEPALM,
                    :ZENHEADBUTT,:SMACKDOWN,:STORMTHROW,:PLAYROUGH,:LOWSWEEP].include?(move.id)) || 
                    move.id == :SKYDROP
                if target.fallsIntoVolcano?
                  target.pbInflictTypeScalingFixedDamage(:FIRE,i.totalhp/2,_INTL("{1} knocked {2} into the volcano!",user.pbThis,target.pbThis(true)))
                end
              end
            end
            if target.hasActiveAbility?(:AFTERMATH,true) && target.fainted? && ![9,29].include?($fefieldeffect)
              @battle.pbShowAbilitySplash(target)
              if !@battle.moldBreaker
                if @battle.dampBattler?
                  @battle.pbDisplay(_INTL("The dampness prevents {1}'s {2} from working!",target.pbThis(true),target.abilityName))
                end
              end
              if !@battle.dampBattler? && user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                @battle.scene.pbDamageAnimation(user)
                if [11,40,45].include?($fefieldeffect)
                  user.pbReduceHP(user.totalhp/2,false)
                else
                  user.pbReduceHP(user.totalhp/4,false)
                end
                @battle.pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
              end
              @battle.pbHideAbilitySplash(target)
            end
            r = @battle.pbRandom(100)
            if (target.hasActiveAbility?(:CUTECHARM) || target.hasActiveAbility?(:FLUFFY) &&
               $fefieldeffect == 44) && (r < 30 || [6,30,35,48].include?($fefieldeffect) &&
               r < 60) && $fefieldeffect != 29
              @battle.pbShowAbilitySplash(target)
              if user.pbCanAttract?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                msg = nil
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  msg = _INTL("{1}'s {2} made {3} fall in love!",target.pbThis,target.abilityName,user.pbThis(true))
                end
                user.pbAttract(target,msg)
              end
              @battle.pbHideAbilitySplash(target)
            end
            r = @battle.pbRandom(100)
            if target.hasActiveAbility?(:EFFECTSPORE,true) && (r < 30 || ([2,15,19,42,47].include?($fefieldeffect) ||
               $fefieldeffect == 33 && $fecounter >= 2) && r < 60)
              @battle.pbShowAbilitySplash(target)
              if user.affectedByPowder?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                if $fefieldeffect == 19
                  user.pbCheckAndInflictRandomStatus(target)
                else
                  case rand(3)
                  when 0
                    if user.pbCanSleep?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                      msg = nil
                      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                        msg = _INTL("{1}'s {2} made {3} fall asleep!",target.pbThis,target.abilityName,user.pbThis(true))
                      end
                      user.pbSleep(msg)
                    end
                  when 1
                    if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                      msg = nil
                      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                        msg = _INTL("{1}'s {2} poisoned {3}!",target.pbThis,target.abilityName,user.pbThis(true))
                      end
                      user.pbPoison(target,msg)
                    end
                  when 2
                    if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                      msg = nil
                      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                        msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",target.pbThis,target.abilityName,user.pbThis(true))
                      end
                      user.pbParalyze(target,msg)
                    end
                  end
                end
              end
              @battle.pbHideAbilitySplash(target)
            end
            r = @battle.pbRandom(100)
            if target.hasActiveAbility?(:FLAMEBODY,true) && (r < 10 || r < 30 && ![3,13,28].include?($fefieldeffect) ||
               r < 60 && [7,12,16,49].include?($fefieldeffect)) && !([8,26].include?($fefieldeffect) &&
               target.grounded?) && ![35,39,46].include?($fefieldeffect)
              @battle.pbShowAbilitySplash(target)
              if user.pbCanBurn?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                msg = nil
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  msg = _INTL("{1}'s {2} burned {3}!",target.pbThis,target.abilityName,user.pbThis(true))
                end
                user.pbBurn(target,msg)
              end
              @battle.pbHideAbilitySplash(target)
            end
            r = @battle.pbRandom(100)
            if target.hasActiveAbility?(:POISONPOINT,true) && (r < 30 || [19,41,42,47,49].include?($fefieldeffect) &&
               r < 60)
              @battle.pbShowAbilitySplash(target)
              if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                msg = nil
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  msg = _INTL("{1}'s {2} poisoned {3}!",target.pbThis,target.abilityName,user.pbThis(true))
                end
                user.pbPoison(target,msg)
              end
              @battle.pbHideAbilitySplash(target)
            end
            r = @battle.pbRandom(100)
            if target.hasActiveAbility?(:STATIC,true) && (r < 30 || [1,18,43,49].include?($fefieldeffect) &&
               r < 60) && $fefieldeffect != 22 && !([8,21,26].include?($fefieldeffect) && 
               user.grounded?)
              @battle.pbShowAbilitySplash(target)
              if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                msg = nil
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",target.pbThis,target.abilityName,user.pbThis(true))
                end
                user.pbParalyze(target,msg)
              end
              @battle.pbHideAbilitySplash(target)
            end
            if target.hasActiveAbility?(:FLUFFY,true) && [1,18].include?($fefieldeffect) &&
               @battle.pbRandom(100) < 30
              @battle.pbShowAbilitySplash(target)
              if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                msg = nil
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",target.pbThis,target.abilityName,user.pbThis(true))
                end
                user.pbParalyze(target,msg)
              end
              @battle.pbHideAbilitySplash(target)
            end
            if target.hasActiveAbility?(:GOOEY,true) && !([20,48,49].include?($fefieldeffect) &&
               target.grounded?) && ![12,39,46].include?($fefieldeffect)
              if [8,26,41].include?($fefieldeffect)
                user.pbLowerStatStageByAbility(:SPEED,2,target,true,true)
              else
                user.pbLowerStatStageByAbility(:SPEED,1,target,true,true)
              end
              if $fefieldeffect == 19
                user.pbCheckAndInflictRandomStatus(target)
              end
            end
            if target.hasActiveAbility?(:TANGLINGHAIR,true)
              if [8,26].include?($fefieldeffect)
                user.pbLowerStatStageByAbility(:SPEED,2,target,true,true)
              else
                user.pbLowerStatStageByAbility(:SPEED,1,target,true,true)
              end
            end
            if target.hasActiveAbility?(:IRONBARBS,true)
              @battle.pbShowAbilitySplash(target)
              if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                @battle.scene.pbDamageAnimation(user)
                user.pbReduceHP(user.totalhp/8,false)
                if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  @battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
                else
                  @battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,target.pbThis(true),target.abilityName))
                end
              end
              @battle.pbHideAbilitySplash(target)
            end
            if target.hasActiveAbility?(:ROUGHSKIN,true) && !([8,26].include?($fefieldeffect) && 
               target.grounded?)
              @battle.pbShowAbilitySplash(target)
              if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                @battle.scene.pbDamageAnimation(user)
                if [14,45].include?($fefieldeffect)
                  user.pbReduceHP(user.totalhp/4,false)
                else
                  user.pbReduceHP(user.totalhp/8,false)
                end
                if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  @battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
                else
                  @battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,target.pbThis(true),target.abilityName))
                end
              end
              @battle.pbHideAbilitySplash(target)
            end
            if target.hasActiveAbility?(:MUMMY,true) && !(user.unstoppableAbility? || 
               user.ability == ability) && $fefieldeffect != 29
              oldAbil = nil
              @battle.pbShowAbilitySplash(target) if user.opposes?(target)
              oldAbil = GameData::Ability.try_get(user.ability_id)
              @battle.pbShowAbilitySplash(user,true,false) if user.opposes?(target)
              user.ability = GameData::Ability.try_get(@ability_id)
              @battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("{1}'s Ability became {2}!",user.pbThis,user.abilityName))
              else
                @battle.pbDisplay(_INTL("{1}'s Ability became {2} because of {3}!",user.pbThis,user.abilityName,target.pbThis(true)))
              end
              @battle.pbHideAbilitySplash(user) if user.opposes?(target)
              @battle.pbHideAbilitySplash(target) if user.opposes?(target)
              user.pbOnAbilityChanged(oldAbil) if oldAbil
            end
            if target.hasActiveAbility?(:PERISHBODY,true) && user.effects[PBEffects::PerishSong] == 0
              @battle.pbShowAbilitySplash(target)
              @battle.pbDisplay(_INTL("Both Pokémon will faint in three turns!"))
              user.effects[PBEffects::PerishSong] = 3
              target.effects[PBEffects::PerishSong] = 3 if target.effects[PBEffects::PerishSong] == 0 && 
                                                           ![40,42].include?($fefieldeffect)
              @battle.pbHideAbilitySplash(target)
            end
            r = @battle.pbRandom(100)
            if target.hasActiveAbility?(:HYPNOTICAURA,true) && (r < 30 || [9,29,38,40,42,48].include?($fefieldeffect) &&
               r < 60 || [31,37].include?($fefieldeffect))
              @battle.pbShowAbilitySplash(target)
              if user.pbCanSleep?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                msg = nil
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  msg = _INTL("{1}'s {2} lulled {3} to sleep!",target.pbThis,target.abilityName,user.pbThis(true))
                end
                user.pbSleep(msg)
              end
              @battle.pbHideAbilitySplash(target)
            end
            if target.hasActiveAbility?(:AROMAVEIL,true) && @battle.pbRandom(100) < 30 &&
               $fefieldeffect == 42
              @battle.pbShowAbilitySplash(target)
              if user.pbCanSleep?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                msg = nil
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  msg = _INTL("{1}'s {2} lulled {3} to sleep!",target.pbThis,target.abilityName,user.pbThis(true))
                end
                user.pbSleep(msg)
              end
              @battle.pbHideAbilitySplash(target)
            end
            if target.hasActiveAbility?(:SPYGEAR) && target.effects[PBEffects::SpyGear] == 3 # Hidden Knife
              if user.pbReduceHP(user.totalhp/8) > 0
                @battle.pbDisplay(_INTL("{1} stabbed {2} with its Hidden Knife!",target.pbThis,user.pbThis(true)))
              end
            end
            if target.hasActiveAbility?(:PRICKLY) && !user.effects[PBEffects::Prickly]
              user.effects[PBEffects::Prickly] = true
              @battle.pbDisplay(_INTL("{1} pricked {2} with its quills!",target.pbThis,user.pbThis(true)))
            end
            if target.hasActiveAbility?(:ALPHABETIZATION,true)
              if target.checkAlphabetizationForm(13) && user.pbCanParalyze?(target,false)
                user.pbParalyze(target,_INTL("{1}'s {2} (Nuzzle) paralyzed {3}! It may be unable to move!",target.pbThis,target.abilityName,user.pbThis(true)))
              end
            end
            if target.hasActiveAbility?(:FRAGRANTSHOCK,true)
              if user.pbCanAttract?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
                msg = nil
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  msg = _INTL("{1}'s {2} made {3} fall in love!",target.pbThis,target.abilityName,user.pbThis(true))
                end
                user.pbAttract(target,msg)
              elsif user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                msg = nil
                if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",target.pbThis,target.abilityName,user.pbThis(true))
                end
                user.pbParalyze(target,msg)
              end
            end
          end
          # Contact and non-contact
          if target.hasActiveAbility?(:WANDERINGSPIRIT) && $fefieldeffect != 29 && 
             (move.pbContactMove?(user) || [40,42].include?($fefieldeffect))
            abilityBlacklist = [
               :DISGUISE,
               :FLOWERGIFT,
               :GULPMISSILE,
               :ICEFACE,
               :IMPOSTER,
               :RECEIVER,
               :RKSSYSTEM,
               :SCHOOLING,
               :STANCECHANGE,
               :WONDERGUARD,
               :ZENMODE,
               # Abilities that are plain old blocked.
               :NEUTRALIZINGGAS
            ]
            failed = false
            abilityBlacklist.each do |abil|
              next if !user.hasActiveAbility?(abil,false,true)
              failed = true
              break
            end
            if !failed
              oldAbil = -1
              oldAbil = GameData::Ability.try_get(user.ability_id)
              @battle.pbDisplay(_INTL("{1}'s {2} swapped its Ability with {3}'s {4}!",target.pbThis,target.abilityName,user.pbThis(true),user.abilityName))
              user.ability = GameData::Ability.try_get(target.ability_id)
              target.ability = oldAbil
              if oldAbil
                user.pbOnAbilityChanged(oldAbil)
                target.pbOnAbilityChanged(GameData::Ability.try_get(user.ability_id))
              end
            end
          end
          r = @battle.pbRandom(100)
          if target.hasActiveAbility?(:CURSEDBODY,true) && user.effects[PBEffects::Disable] == 0 && 
             (r < 30 || $fefieldeffect == 42 && r < 60 || $fefieldeffect == 40) &&
             ![3,29].include?($fefieldeffect)
            regularMove = nil
            user.eachMove do |m|
              next if m.id!=user.lastRegularMoveUsed
              regularMove = m
              break
            end
            if regularMove && !(regularMove.pp==0 && regularMove.total_pp>0)
              @battle.pbShowAbilitySplash(target)
              if !move.pbMoveFailedAromaVeil?(target,user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                user.effects[PBEffects::Disable]     = 3
                user.effects[PBEffects::DisableMove] = regularMove.id
                if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                  @battle.pbDisplay(_INTL("{1}'s {2} was disabled!",user.pbThis,regularMove.name))
                else
                  @battle.pbDisplay(_INTL("{1}'s {2} was disabled by {3}'s {4}!",user.pbThis,regularMove.name,target.pbThis(true),target.abilityName))
                end
                @battle.pbHideAbilitySplash(target)
                user.pbItemStatusCureCheck
              end
              @battle.pbHideAbilitySplash(target)
            end
          end
          if target.hasActiveAbility?(:INNARDSOUT,true) && target.fainted? && !user.dummy
            @battle.pbShowAbilitySplash(target)
            if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
              @battle.scene.pbDamageAnimation(user)
              if [8,19].include?($fefieldeffect)
                user.pbReduceHP(target.damageState.hpLost*2,false)
              else
                user.pbReduceHP(target.damageState.hpLost,false)
              end
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
              else
                @battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,target.pbThis(true),target.abilityName))
              end
            end
            @battle.pbHideAbilitySplash(target)
          end
          if target.hasActiveAbility?(:GULPMISSILE,false,true) && target.form > 0
            @battle.pbShowAbilitySplash(target)
            oldForm = target.form
            target.pbChangeForm(0,"")
            @battle.pbHideAbilitySplash(target)
            if oldForm == 1
              @battle.pbCommonAnimation("CramorantGulp",user,target)
            elsif oldForm == 2
              @battle.pbCommonAnimation("CramorantGorge",user,target)
            end
            user.pbReduceHP(user.totalhp/4) if user.takesIndirectDamage?(true)
            if oldForm == 1
              user.pbLowerStatStageByAbility(:DEFENSE,1,target,false)
            elsif oldForm == 2
              user.pbParalyze(target,"")
            end
          end
          if target.hasActiveAbility?(:ALPHABETIZATION)
            if target.checkAlphabetizationForm(23)
              if user.effects[PBEffects::Disable] == 0 && move.pp > 0
                user.effects[PBEffects::Disable] = 10
                user.effects[PBEffects::DisableMove] = move.id
                @battle.pbDisplay(_INTL("{1}'s {2} (XXXXX) disabled {3}!",target.pbThis,target.abilityName,user.pbThis(true)))
              end
            end
          end
          if target.hasActiveAbility?(:INKJET)
            user.pbLowerStatStageByAbility(:ACCURACY,1,target)
          end
          if target.hasActiveAbility?(:VOODOO,true) && move.physicalMove?
            if user.pbReduceHP(target.damageState.hpLost) > 0
              @battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,target.pbThis(true),target.abilityName))
            end
          end
        end
        # Effect on target
        if !target.fainted?
          if move.pbContactMove?(user)
            # Contact-Only
            if target.hasActiveAbility?(:OVERLORD) && $fefieldeffect != 9
              if $fefieldeffect == 29
                target.pbLowerStatStageByAbility(:ATTACK,1,target)
              elsif $fefieldeffect == 32
                target.pbRaiseStatStageByAbility(:ATTACK,2,target)
              elsif $fefieldeffect == 39
                target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,2,target)
              else
                target.pbRaiseStatStageByAbility(:ATTACK,1,target)
              end
            end
            if target.effects[PBEffects::Prickly]
              if [12,49].include?($fefieldeffect)
                prickAmount = target.totalhp/4
              else
                prickAmount = target.totalhp/8
              end
              if target.pbReduceHP(prickAmount) > 0
                @battle.pbDisplay(_INTL("{1} was hurt by the pricks planted in it!",target.pbThis))
              end
            end
          end
          # Contact and non-contact
          if target.hasActiveAbility?(:ANGERPOINT) && target.damageState.critical && 
             ![9,20,48].include?($fefieldeffect)
            if $fefieldeffect == 29 && target.pbCanLowerStatStage?(:ATTACK,target)
              @battle.pbShowAbilitySplash(target)
              target.stages[:ATTACK] = -6
              @battle.pbCommonAnimation("StatDown",target)
              @battle.pbDisplay(_INTL("{1}'s feelings from {2} were deemed sinful, minimizing its {3}!",target.pbThis,target.abilityName,GameData::Stat.get(:ATTACK).name))
              @battle.pbHideAbilitySplash(target)
            elsif target.pbCanRaiseStatStage?(:ATTACK,target)
              @battle.pbShowAbilitySplash(target)
              target.stages[:ATTACK] = 6
              @battle.pbCommonAnimation("StatUp",target)
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("{1} maxed its {2}!",target.pbThis,GameData::Stat.get(:ATTACK).name))
              else
                @battle.pbDisplay(_INTL("{1}'s {2} maxed its {3}!",target.pbThis,target.abilityName,GameData::Stat.get(:ATTACK).name))
              end
              if $fefieldeffect == 45
                target.pbRaiseStatStage(:SPEED,2,target,false)
              elsif [12,16].include?($fefieldeffect)
                if target.pbLowerStatStageByCause(:SPEED,2,target,nil)
                  @battle.pbDisplay(_INTL("The hot atmosphere exhausted {1}, harshly lowering its Speed!",target.pbThis(true)))
                end
              elsif $fefieldeffect == 5
                if target.pbLowerStatStageByCause(:ACCURACY,1,target,nil)
                  @battle.pbDisplay(_INTL("{1} lost concentration, lowering its Accuracy!",target.pbThis))
                end
              elsif $fefieldeffect == 39 && target.pbCanIncreaseStatStage?(:SPECIAL_ATTACK,target)
                target.stages[PBStats::SPECIAL_ATTACK]=6
                @battle.pbDisplay(_INTL("{1}'s Sp. Atk was also maximized!",target.pbThis))
              end
              @battle.pbHideAbilitySplash(target)
            end
          end
          if target.hasActiveAbility?(:JUSTIFIED) && (move.calcTypes.include?(:DARK) ||
             $fefieldeffect == 32 && move.calcTypes.include?(:DRAGON)) && $fefieldeffect != 40
            if $fefieldeffect == 29
              target.pbRaiseStatStageByAbility(:ATTACK,2,target)
            else
              target.pbRaiseStatStageByAbility(:ATTACK,1,target)
            end
          end
          if target.hasActiveAbility?(:RATTLED) && (move.calcTypes.include?(:BUG) || 
             move.calcTypes.include?(:DARK) || move.calcTypes.include?(:GHOST) ||
             $fefieldeffect == 32 && move.calcTypes.include?(:DRAGON) || $fefieldeffect == 45 &&
             move.calcTypes.include?(:FIGHTING)) && ![20,48].include?($fefieldeffect)
            target.pbRaiseStatStageByAbility(:SPEED,1,target)
          end
          if target.hasActiveAbility?(:STAMINA) && $fefieldeffect != 48
            if $fefieldeffect == 5
              target.pbRaiseStatStageByAbility([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,target)
            elsif [12,49].include?($fefieldeffect)
              target.pbRaiseStatStageByAbility([:DEFENSE,:SPECIAL_DEFENSE],1,target)
            elsif $fefieldeffect == 17
              target.pbRaiseStatStageByAbility([:ATTACK,:DEFENSE],1,target)
            else
              target.pbRaiseStatStageByAbility(:DEFENSE,1,target)
            end
          end
          if target.hasActiveAbility?(:WATERCOMPACTION) && move.calcTypes.include?(:WATER)
            if $fefieldeffect == 20
              target.pbRaiseStatStageByAbility([:DEFENSE,:SPECIAL_DEFENSE],2,target)
            else
              target.pbRaiseStatStageByAbility(:DEFENSE,2,target)
            end
          end
          if target.hasActiveAbility?(:STEADFAST) && $fefieldeffect == 5
            target.pbRaiseStatStageByAbility(:SPEED,1,target)
          end
          if target.hasActiveAbility?(:WEAKARMOR) && move.physicalMove? && $fefieldeffect != 14
            @battle.pbShowAbilitySplash(target)
            target.pbLowerStatStageByAbility(:DEFENSE,1,target,false)
            target.pbRaiseStatStageByAbility(:SPEED,2,target,false)
            @battle.pbHideAbilitySplash(target)
          end
          if target.hasActiveAbility?(:STEAMENGINE) && (move.calcTypes.include?(:FIRE) || 
             move.calcTypes.include?(:WATER)) && !($fefieldeffect == 8 && target.grounded?) &&
             ![13,39,46].include?($fefieldeffect)
            target.pbRaiseStatStageByAbility(:SPEED,6,target)
            if $fefieldeffect == 17
              target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,2,target)
            end
          end
          if target.hasActiveAbility?(:SANDSPIT,true) && !([21,26].include?($fefieldeffect) && 
             target.grounded?)
            if ![:HarshSun,:HeavyRain,:StrongWinds].include?(@battle.field.weather) &&
               @battle.field.weather != :Sandstorm
              @battle.pbShowAbilitySplash(target)
              if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("{1} spat out a sandstorm!",target.pbThis))
              end
              fixedDuration = false
              fixedDuration = true if Settings::FIXED_DURATION_WEATHER_FROM_ABILITY
              @battle.pbStartWeather(target,:Sandstorm,fixedDuration)
            end
          end
          if target.hasActiveAbility?(:COTTONDOWN,true) && ![3,7,22,43].include?($fefieldeffect) &&
             !([8,21,26].include?($fefieldeffect) && target.grounded?)
            @battle.pbShowAbilitySplash(target)
            if [2,15].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 3
              increment = 2
            else
              increment = 1
            end
            target.eachOpposing{|b|
              b.pbLowerStatStageByAbility(:SPEED,increment,target)
            }
            target.eachAlly{|b|
              b.pbLowerStatStageByAbility(:SPEED,increment,target)
            }
            @battle.pbHideAbilitySplash(target)
          end
          if target.hasActiveAbility?(:TRACE) && [5,30].include?($fefieldeffect) && 
             @battle.pbRandom(2) == 0
            target.pbUseMoveSimple(move.id,-1,user.index) # Uses back at the user
          end
          if target.hasActiveAbility?(:COMPULSION) && target.damageState.critical && 
             ![29,48].include?($fefieldeffect) && target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
            @battle.pbShowAbilitySplash(target)
            target.stages[:SPECIAL_ATTACK] = 6
            @battle.pbCommonAnimation("StatUp",target)
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("{1} maxed its {2}!",target.pbThis,GameData::Stat.get(:SPECIAL_ATTACK).name))
            else
              @battle.pbDisplay(_INTL("{1}'s {2} maxed its {3}!",target.pbThis,target.abilityName,GameData::Stat.get(:SPECIAL_ATTACK).name))
            end
            if $fefieldeffect == 5
              if target.pbLowerStatStageByCause(:ACCURACY,1,target,nil)
                @battle.pbDisplay(_INTL("{1} lost concentration, lowering its Accuracy!",target.pbThis))
              end
            elsif $fefieldeffect == 31
              target.pbRaiseStatStageByAbility(:ACCURACY,1,target)
            elsif $fefieldeffect == 39
              target.pbRaiseCritRatio(3,target)
            end
            @battle.pbHideAbilitySplash(target)
          end
          if target.hasActiveAbility?(:SUPERNOVA) && Effectiveness.super_effective?(target.damageState.typeMod)
            @battle.pbDisplay(_INTL("{1} burst in a supernova!",target.pbThis))
            if $fefieldeffect == 9
              target.pbRaiseStatStage([:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED],3,target)
            elsif $fefieldeffect == 30
              target.pbRaiseStatStage([:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED,:EVASION],2,target)
            else
              target.pbRaiseStatStage([:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED],2,target)
            end
            target.pbReduceHP(target.hp-1,false,true,true,true) if $fefieldeffect != 34
          end
          if target.hasActiveAbility?(:ALPHABETIZATION)
            if target.checkAlphabetizationForm(0)
              target.pbRaiseStatStageByCause([:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED,:ACCURACY,:EVASION],2,target,target.abilityName+" (Anger)")
            end
            if target.checkAlphabetizationForm(4)
              target.pbRaiseStatStageByCause([:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED,:ACCURACY,:EVASION],1,target,target.abilityName+" (Engage)")
              if !target.effects[PBEffects::TracedMove]
                target.effects[PBEffects::TracedMove] = true
                target.pbUseMoveSimple(move.id)
              end
            end
            if target.checkAlphabetizationForm(24)
              target.pbLowerStatStageByCause([:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED],1,target,target.abilityName+" (Yield)")
            end
          end
          if target.hasActiveAbility?(:ASSEMBLY) && move.physicalMove?
            target.pbLowerStatStageByAbility(:SPEED,1,target,false)
            target.pbRaiseStatStageByAbility(:DEFENSE,2,target,false)
          end
          if $fefieldeffect == 34
            if [:NAUGHTY,:SASSY].include?(user.pokemon.nature_id) && move.damagingMove? && 
               target.effects[PBEffects::HealBlock] == 0 && !move.pbMoveFailedAromaVeil?(user,target,false)
              target.effects[PBEffects::HealBlock] = 5
              @battle.pbDisplay(_INTL("{1}'s astrological sign (Scorpio) inflicted a Heal Block on {2}!",user.pbThis,target.pbThis(true)))
              target.pbItemStatusCureCheck
            elsif user.pokemon.nature_id == :IMPISH && @battle.pbRandom(2) == 0 &&
                  !target.effects[PBEffects::Curse]
              @battle.pbDisplay(_INTL("{1}'s astrological sign (Ophiuchus) laid a curse on {2}!",user.pbThis,target.pbThis(true)))
              target.effects[PBEffects::Curse] = true
            end
          end
        end
      end
      # Damaging and non-damaging moves
      if !target.fainted? && target.index != user.index && !target.hasShieldDust? &&
         !@battle.moldBreaker
        # Effect on target
        if target.hasActiveAbility?(:LIVEWIRE) && move.calcTypes.include?(:ELECTRIC)
          target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,target)
        end
      end
      # User's ability
      if target.damageState.calcDamage>0 && !target.damageState.substitute
        # Damaging moves
        #BattleHandlers.triggerUserAbilityOnHit(user.ability,user,target,move,@battle)
        if !target.hasShieldDust? && !@battle.moldBreaker
          if !target.fainted?
            # Effect on target
            if move.pbContactMove?(user)
              # Contact-Only
              r = @battle.pbRandom(100)
              if user.hasActiveAbility?(:POISONTOUCH,true) && (r < 30 || [10,19,41,42].include?($fefieldeffect) &&
                 r < 60)
                @battle.pbShowAbilitySplash(user)
                if target.pbCanPoison?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                  msg = nil
                  if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                    msg = _INTL("{1}'s {2} poisoned {3}!",user.pbThis,user.abilityName,target.pbThis(true))
                  end
                  target.pbPoison(user,msg)
                end
                @battle.pbHideAbilitySplash(user)
              end
              if user.hasActiveAbility?(:CUTECHARM) && [31,34].include?($fefieldeffect) &&
                 @battle.pbRandom(100) < 30 && !user.fainted?
                @battle.pbShowAbilitySplash(user)
                if target.pbCanAttract?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                  msg = nil
                  if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                    msg = _INTL("{1}'s {2} made {3} fall in love!",user.pbThis,user.abilityName,target.pbThis(true))
                  end
                  target.pbAttract(user,msg)
                end
                @battle.pbHideAbilitySplash(user)
              end
              r == @battle.pbRandom(100)
              if user.hasActiveAbility?(:VIRALFROST,true) && (r < 30 || r < 50 && 
                 [13,28,39,46].include?($fefieldeffect)) && ![12,16].include?($fefieldeffect)
                @battle.pbShowAbilitySplash(user)
                if target.pbCanFreeze?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
                  msg = nil
                  if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                    msg = _INTL("{1}'s {2} froze {3}!",user.pbThis,user.abilityName,target.pbThis(true))
                  end
                  target.pbFreeze(user,msg)
                end
                @battle.pbHideAbilitySplash(user)
              end
              if user.hasActiveAbility?(:THRUST,true) && target.lastMoveUsed && GameData::Move.get(target.lastMoveUsed).statusMove? &&
                 $fefieldeffect != 46
                target.forceSwitchOut(user,false,_INTL("{1}'s {2} forced {3} to switch out!",user.pbThis,user.abilityName,target.pbThis(true)))
              end
              if user.hasActiveAbility?(:SPYGEAR) && user.effects[PBEffects::SpyGear] == 3 # Hidden Knife
                if target.pbReduceHP(target.totalhp/8) > 0
                  @battle.pbDisplay(_INTL("{1} stabbed {2} with its Hidden Knife!",user.pbThis,target.pbThis(true)))
                end
              end
              if user.hasActiveAbility?(:PRICKLY) && !target.effects[PBEffects::Prickly]
                target.effects[PBEffects::Prickly] = true
                @battle.pbDisplay(_INTL("{1} pricked {2} with its quills!",user.pbThis,target.pbThis(true)))
                if [12,49].include?($fefieldeffect)
                  prickAmount = target.totalhp/4
                else
                  prickAmount = target.totalhp/8
                end
                if target.pbReduceHP(prickAmount) > 0 # Needed only in this case because damage check is before effect application
                  @battle.pbDisplay(_INTL("{1} was hurt by the pricks planted in it!",target.pbThis))
                end
              end
              r = @battle.pbRandom(100)
              if user.hasActiveAbility?(:SCORPIONSTINGER,true) && (r < 30 || [12,49].include?($fefieldeffect) &&
                 r < 60)
                if target.pbCanParalyze?(user,false)
                  msg = _INTL("{1}'s {2} paralyzed {3}!",user.pbThis,user.abilityName,target.pbThis(true))
                  target.pbParalyze(user,msg)
                end
              end
            end
            # Contact and non-contact
            if user.hasActiveAbility?(:WANDERINGSPIRIT) && $fefieldeffect == 40
              abilityBlacklist = [
                 :DISGUISE,
                 :FLOWERGIFT,
                 :GULPMISSILE,
                 :ICEFACE,
                 :IMPOSTER,
                 :RECEIVER,
                 :RKSSYSTEM,
                 :SCHOOLING,
                 :STANCECHANGE,
                 :WONDERGUARD,
                 :ZENMODE,
                 # Abilities that are plain old blocked.
                 :NEUTRALIZINGGAS
              ]
              failed = false
              abilityBlacklist.each do |abil|
                next if !target.hasActiveAbility?(abil,false,true)
                failed = true
                break
              end
              if !failed
                oldAbil = -1
                @battle.pbShowAbilitySplash(user) if target.opposes?(user)
                oldAbil = GameData::Ability.try_get(target.ability_id)
                @battle.pbShowAbilitySplash(target,true,false) if target.opposes?(user)
                target.ability = GameData::Ability.try_get(user.ability_id)
                user.ability = oldAbil
                if target.opposes?(user)
                  @battle.pbReplaceAbilitySplash(target)
                  @battle.pbReplaceAbilitySplash(user)
                end
                @battle.pbDisplay(_INTL("{1}'s {2} swapped its Ability with {3}'s {4}!",user.pbThis,user.abilityName,target.pbThis(true),target.abilityName))
                @battle.pbHideAbilitySplash(target)
                @battle.pbHideAbilitySplash(user) if target.opposes?(user)
                if oldAbil>=0
                  target.pbOnAbilityChanged(oldAbil)
                  user.pbOnAbilityChanged(GameData::Ability.try_get(target.ability_id))
                end
              end
            end
            if user.hasActiveAbility?(:GULPMISSILE,false,true) && user.form == 0 &&
               (move.calcTypes.include?(:WATER) && [20,21,26,48].include?($fefieldeffect) || 
               target.grounded? && [21,26].include?($fefieldeffect) || $fefieldeffect == 22) && 
               move.damagingMove?
              newForm = (user.hp > (user.totalhp/2)) ? 1 : 2
              user.pbChangeForm(newForm,"")
            end
            if user.hasActiveAbility?(:DRENCH) && $fefieldeffect == 22 && move.calcTypes.include?(:WATER) &&
               target.canChangeType? && target.pbHasOtherType?(:WATER)
              target.pbChangeTypes(:WATER)
              @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",target.pbThis,GameData::Type.get(:WATER).name))
            end
            if user.hasActiveAbility?(:BLOOM) && @battle.pbRandom(100) < 30 && target.effects[PBEffects::LeechSeed] < 0 && 
               !target.fainted? && !target.pbHasType?(:GRASS) && ![7,10,11,12,46].include?($fefieldeffect)
              if [2,15,47].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
                if target.index != user.index && move.calcTypes.include?(:GRASS)
                  target.effects[PBEffects::LeechSeed] = user.index
                  @battle.pbDisplay(_INTL("{1} planted a seed in {2}!",user.pbThis,target.pbThis(true)))
                end
              else
                for m in [:SEEDBOMB,:BULLETSEED,:WORRYSEED,:SEEDFLARE]
                  if move.id == m
                    target.effects[PBEffects::LeechSeed] = user.index
                    @battle.pbDisplay(_INTL("{1} planted a seed in {2}!",user.pbThis,target.pbThis(true)))
                    break
                  end
                end
              end
            end
            if user.hasActiveAbility?(:MAGICWAND) && (@battle.pbRandom(100) < 50 ||
               [9,37,40,42].include?($fefieldeffect)) && moveaddlEffect == 0 && move.specialMove?
              target.pbCheckAndInflictRandomStatus(user,false,move)
            end
            if $fefieldeffect == 42 && target.effects[PBEffects::BewitchedMark]
              if move.calcTypes.include?(:FIRE)
                target.effects[PBEffects::BewitchedMark] = false
              end
              if move.calcTypes.include?(:WATER)
                target.pbLowerStatStage([:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED],1)
                target.effects[PBEffects::BewitchedMark] = false
              end
            end
            if user.hasActiveAbility?(:SCARECROW) && target.pbHasType?(:FLYING)
              target.forceSwitchOut(user,false,_INTL("{1}'s {2} forced {3} out!",user.pbThis,user.abilityName,target.pbThis(true)))
            end
            if user.hasActiveAbility?(:INKJET)
              target.pbLowerStatStageByAbility(:ACCURACY,1,user)
            end
            if user.hasActiveAbility?(:GLEAMEYES)
              if target.pbOwnSide.effects[PBEffects::LightScreen]>0
                target.pbOwnSide.effects[PBEffects::LightScreen] = 0
                user.pbRaiseStatStageByAbility(:SPEED,1,user)
                @battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",target.pbTeam))
              end
              if target.pbOwnSide.effects[PBEffects::Reflect]>0
                target.pbOwnSide.effects[PBEffects::Reflect] = 0
                user.pbRaiseStatStageByAbility(:SPEED,1,user)
                @battle.pbDisplay(_INTL("{1}'s Reflect wore off!",target.pbTeam))
              end
              if target.pbOwnSide.effects[PBEffects::AuroraVeil]>0
                target.pbOwnSide.effects[PBEffects::AuroraVeil] = 0
                user.pbRaiseStatStageByAbility(:SPEED,1,user)
                @battle.pbDisplay(_INTL("{1}'s Light Screen wore off!",target.pbTeam))
              end
              if target.effects[PBEffects::BanefulBunker]
                user.pbRaiseStatStageByAbility(:SPEED,1,user)
                target.effects[PBEffects::BanefulBunker] = false
                @battle.pbDisplay(_INTL("{1}'s Baneful Bunker was destroyed!",target.pbThis))
              end
              if target.effects[PBEffects::KingsShield]
                user.pbRaiseStatStageByAbility(:SPEED,1,user)
                target.effects[PBEffects::KingsShield] = false
                @battle.pbDisplay(_INTL("{1}'s King's Shield was destroyed!",target.pbThis))
              end
              if target.effects[PBEffects::Obstruct]
                user.pbRaiseStatStageByAbility(:SPEED,1,user)
                target.effects[PBEffects::Obstruct] = false
                @battle.pbDisplay(_INTL("{1}'s Obstruction was destroyed!",target.pbThis))
              end
              if target.effects[PBEffects::Protect]
                user.pbRaiseStatStageByAbility(:SPEED,1,user)
                target.effects[PBEffects::Protect] = false
                @battle.pbDisplay(_INTL("{1}'s Protection was destroyed!",target.pbThis))
              end
              if target.effects[PBEffects::SpikyShield]
                user.pbRaiseStatStageByAbility(:SPEED,1,user)
                target.effects[PBEffects::SpikyShield] = false
                @battle.pbDisplay(_INTL("{1}'s Spiky Shield was destroyed!",target.pbThis))
              end
              if target.pbOwnSide.effects[PBEffects::CraftyShield]
                user.pbRaiseStatStageByAbility(:SPEED,1,user)
                target.pbOwnSide.effects[PBEffects::CraftyShield] = false
                @battle.pbDisplay(_INTL("{1}'s Crafty Shield was destroyed!",target.pbTeam))
              end
              if target.pbOwnSide.effects[PBEffects::MatBlock]
                user.pbRaiseStatStageByAbility(:SPEED,1,user)
                target.pbOwnSide.effects[PBEffects::MatBlock] = false
                @battle.pbDisplay(_INTL("{1}'s Mat was destroyed!",target.pbTeam))
              end
              if target.pbOwnSide.effects[PBEffects::QuickGuard]
                user.pbRaiseStatStageByAbility(:SPEED,1,user)
                target.pbOwnSide.effects[PBEffects::QuickGuard] = false
                @battle.pbDisplay(_INTL("{1}'s Quick Guard was destroyed!",target.pbTeam))
              end
              if target.pbOwnSide.effects[PBEffects::WideGuard]
                user.pbRaiseStatStageByAbility(:SPEED,1,user)
                target.pbOwnSide.effects[PBEffects::WideGuard] = false
                @battle.pbDisplay(_INTL("{1}'s Wide Guard was destroyed!",target.pbTeam))
              end
            end
            if user.hasActiveAbility?(:WOUNDING) && move.slashingMove? && target.effects[PBEffects::HealBlock] == 0 &&
               !target.aromaVeilProtected?
              target.effects[PBEffects::HealBlock] = 5
              @battle.pbDisplay(_INTL("{1}'s {2} prevented {3} from healing!",user.pbThis,user.abilityName,target.pbThis(true)))
              target.pbItemStatusCureCheck
            end
            if user.hasActiveAbility?(:TACTICALPLUMAGE)
              if target.pbReduceHP(user.attack/8) > 0
                @battle.pbDisplay(_INTL("{1}'s {2} hurt {3}!",user.pbThis,user.abilityName,target.pbThis(true)))
              end
            end
          end
          # Effect on user
          if user.hasActiveAbility?(:BLACKLIGHTPROPULSION) && ($fefieldeffect == 4 ||
             Effectiveness.super_effective?(target.damageState.typeMod)) && $fefieldeffect != 9
            if [30,34,38].include?($fefieldeffect)
              user.pbRaiseStatStageByAbility(:SPEED,2,user)
            else
              user.pbRaiseStatStageByAbility(:SPEED,1,user)
            end
          end
          if user.effects[PBEffects::Prickly]
            if [12,49].include?($fefieldeffect)
              prickAmount = user.totalhp/4
            else
              prickAmount = user.totalhp/8
            end
            if user.pbReduceHP(prickAmount) > 0
              @battle.pbDisplay(_INTL("{1} was hurt by the pricks planted in it!",user.pbThis))
            end
          end
          if user.hasActiveAbility?(:BLACKLIGHTABSORPTION) && ($fefieldeffect == 4 ||
             Effectiveness.super_effective?(target.damageState.typeMod)) && user.canHeal? &&
             $fefieldeffect != 9
            if [30,34,38].include?($fefieldeffect)
              user.pbRecoverHP(target.damageState.calcDamage/2)
            else
              user.pbRecoverHP(target.damageState.calcDamage/4)
            end
            @battle.pbDisplay(_INTL("{1}'s {2} drained some of the damage!",user.pbThis,user.abilityName))
          end
          if $fefieldeffect == 31 && !user.near?(target)
            user.effects[PBEffects::FairyTaleRoles].push(7)
            @battle.pbDisplay(_INTL("{1} was given the Ranger role!",user.pbThis))
          end
          if $fefieldeffect == 34
            if [:RELAXED,:SERIOUS].include?(user.pokemon.nature_id) && @battle.pbRandom(2) == 0
              if @battle.pbRandom(2) == 0
                user.pbRaiseStatStageByCause(:DEFENSE,1,user,"astrological sign (Capricorn)")
              else
                user.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,user,"astrological sign (Capricorn)")
              end
            elsif [:LONELY,:QUIET].include?(user.pokemon.nature_id) && @battle.pbRandom(2) == 0
              if @battle.pbRandom(2) == 0
                user.pbRaiseStatStageByCause(:ATTACK,1,user,"astrological sign (Aquarius)")
              else
                user.pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,user,"astrological sign (Aquarius)")
              end
            elsif [:TIMID,:NAIVE].include?(user.pokemon.nature_id) && user.canHeal?
              user.pbRecoverHP((target.damageState.calcDamage*0.25).round)
              @battle.pbDisplay(_INTL("{1}'s astrological sign (Pisces) drained some of the damage!",user.pbThis))
            end
          end
          if user.hasActiveAbility?(:ENERGYBANK) && user.canHeal? && move.specialMove? &&
             (move.calcTypes.include?(:GRASS) || move.calcTypes.include?(:ELECTRIC))
            user.pbRecoverHP(target.damageState.calcDamage/2)
            @battle.pbDisplay(_INTL("{1}'s {2} drained some of the damage!",user.pbThis,user.abilityName))
          end
          if user.hasActiveAbility?(:SOULSEARCHER) && target.pbHasType?(:GHOST)
            if !target.fainted? # Remove target's Ghost-typing
              target.type1 = :QMARKS if target.type1 == :GHOST
              target.type2 = :QMARKS if target.type2 == :GHOST
              target.effects[PBEffects::Type3] = :QMARKS if target.effects[PBEffects::Type3] == :GHOST
              @battle.pbDisplay(_INTL("{1}'s {2} purified {3} of its Ghost-typing!",user.pbThis,user.abilityName,target.pbThis(true)))
            end
            if user.canHeal?
              user.pbRecoverHP(target.damageState.calcDamage/2)
              @battle.pbDisplay(_INTL("{1} drained some of the damage!",user.pbThis))
            end
          end
        end
      end
      # Damaging and non-damaging moves
      if !target.fainted? && target.index != user.index
        # Effect on Target
        if move.soundMove?(user)
          if user.hasActiveAbility?(:QUIP) && $fefieldeffect != 29 && 
             !target.fainted? && !(target.hasShieldDust? && !@battle.moldBreaker)
            if $fefieldeffect == 6
              increment = 2
            else
              increment = 1
            end
            target.pbLowerStatStageByAbility(target.highestStat,increment,user)
          end
          if user.hasActiveAbility?(:SEDUCTIVECRY) && target.pbCanAttract?(user,false)
            target.pbAttract(user,_INTL("{1}'s {2} made {3} fall in love!",user.pbThis,user.abilityName,target.pbThis(true)))
          end
        end
        if user.hasActiveAbility?(:FLAMESPIRAL) && move.calcTypes.include?(:FIRE) &&
           !([8,21,26].include?($fefieldeffect) && user.grounded?)
          if [7,16].include?($fefieldeffect)
            target.pbInflictTypeScalingFixedDamage(:FIRE,user.spatk/3,_INTL("{1}'s {2} accompanies the attack!",user.pbThis,user.abilityName))
          else
            target.pbInflictTypeScalingFixedDamage(:FIRE,user.spatk/4,_INTL("{1}'s {2} accompanies the attack!",user.pbThis,user.abilityName))
          end
        end
        if user.hasActiveAbility?(:ALPHABETIZATION)
          if user.checkAlphabetizationForm(5)
            worked = false
            for s in [:ATTACK,:DEFENSE,:SPEED,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:ACCURACY,:EVASION]
              if target.stages[s] != 0
                target.stages[s] *= -1
                worked = true
              end
            end
            if worked
              @battle.pbDisplay(_INTL("{1}'s {2} (Find) inverted {3}'s stat changes!",user.pbThis,user.abilityName,target.pbThis(true)))
            end
          end
          if user.checkAlphabetizationForm(12)
            @battle.pbDisplay(_INTL("{1}'s {2} (Make) activated!",user.pbThis,user.abilityName))
            target.pbCheckAndInflictRandomStatus(user,true)
          end
          if user.checkAlphabetizationForm(13) && target.pbCanParalyze?(user,false)
            target.pbParalyze(user,_INTL("{1}'s {2} (Nuzzle) paralyzed {3}! It may be unable to move!",user.pbThis,user.abilityName,target.pbThis(true)))
          end
          if user.checkAlphabetizationForm(19)
            stat = target.highestStat
            if target.pbLowerStatStageByCause(stat,12,user,nil)
              @battle.pbDisplay(_INTL("{1}'s {2} (Tell) minimized {3}'s {4}!",user.pbThis,user.abilityName,target.pbThis(true),GameData::Stat.get(stat).name))
            end
          end
          if user.checkAlphabetizationForm(22)
            target.pbLowerStatStageByCause([:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED,:ACCURACY,:EVASION],2,user,user.abilityName+" (Want)")
          end
        end
        if user.hasActiveAbility?(:RELAXINGRHYTHM) && move.danceMove? && target.pbCanSleep?(user,false) &&
           @battle.pbRandom(100) < 50
          target.pbSleep(_INTL("{1}'s {2} put {3} to sleep!",user.pbThis,user.abilityName,target.pbThis(true)))
        end
        if $fefieldeffect == 40 && target.effects[PBEffects::HauntedScared] != user.index &&
           [:LEER,:GROWL,:NIGHTSHADE,:SCREECH,:GLARE,:NIGHTMARE,:CURSE,:SCARYFACE,
           :MEANLOOK,:TORMENT,:WORRYSEED,:SHADOWSNEAK,:DARKVOID,:QUASH,:EERIEIMPULSE,
           :NEVERENDINGNIGHTMARE].include?(move.id) && !target.pbHasType?(:GHOST) && 
           target.opposes?(user) && !target.hasActiveItem?(:BRIGHTPOWDER)
          target.effects[PBEffects::HauntedScared] = user.index
          @battle.pbDisplay(_INTL("{1} became scared of {2}!",target.pbThis,user.pbThis(true)))
        end
        if user.hasActiveAbility?(:ELECTRICLOVE) && move.calcTypes.include?(:ELECTRIC) &&
           target.pbCanAttract?(user,false)
          target.pbAttract(user,_INTL("{1}'s {2} made {3} fall in love!",user.pbThis,user.abilityName,target.pbThis(true)))
        end
        if user.hasActiveAbility?(:MARACAMOVEMENT) && move.danceMove? && $fefieldeffect != 22
          target.forceSwitchOut(user,false,_INTL("{1}'s {2} forced {3} out!",user.pbThis,user.abilityName,target.pbThis(true)))
        end
        if user.hasActiveAbility?(:BEAUTY) && move.calcTypes.include?(:BUG) && target.pbCanAttract?(user,false,true) &&
           @battle.pbRandom(2) == 0
          target.pbAttract(user,_INTL("{1}'s {2} made {3} fall in love!",user.pbThis,user.abilityName,target.pbThis(true)))
        end
      end
      # Effects on user should be handled in pbEffectsAfterMove
      user.pbItemHPHealCheck
      # Target's item
      if target.itemActive?(true)
        oldHP = user.hp
        if move.function == "18B" && target.pbCanBurn?(user,false,move) && target.effects[PBEffects::BurningJealousy] && # Burning Jealousy
           !target.damageState.substitute
          target.pbBurn(user)
        end
        BattleHandlers.triggerTargetItemOnHit(target.item,user,target,move,@battle)
        user.pbItemHPHealCheck if user.hp<oldHP
      end
      if target.hasActiveAbility?(:ILLUSION) && target.effects[PBEffects::Illusion]
        target.effects[PBEffects::Illusion] = nil
        @battle.scene.pbChangePokemon(target,target.pokemon)
        @battle.pbDisplay(_INTL("{1}'s illusion wore off!",target.pbThis))
        @battle.pbSetSeen(target)
      end
      if target.opposes?(user)
        # Rage
        if target.effects[PBEffects::Rage] && !target.fainted?
          if target.pbCanRaiseStatStage?(:ATTACK,target)
            @battle.pbDisplay(_INTL("{1}'s rage is building!",target.pbThis))
            if [39,45].include?($fefieldeffect)
              target.pbRaiseStatStage(:ATTACK,2,target)
            else
              target.pbRaiseStatStage(:ATTACK,1,target)
            end
          end
        end
        # Beak Blast
        if target.effects[PBEffects::BeakBlast]
          PBDebug.log("[Lingering effect] #{target.pbThis}'s Beak Blast")
          if move.pbContactMove?(user) && user.affectedByContactEffect?
            user.pbBurn(user) if user.pbCanBurn?(target,false,self)
          end
        end
        # Shell Trap (make the trapper move next if the trap was triggered)
        if target.effects[PBEffects::ShellTrap] && @battle.choices[target.index][0]==:UseMove && 
           !target.movedThisRound?
          if target.damageState.hpLost>0 && !target.damageState.substitute && (move.physicalMove? ||
             $fefieldeffect == 48)
            target.tookPhysicalHit              = true
            target.effects[PBEffects::MoveNext] = true
            target.effects[PBEffects::Quash]    = 0
          end
        end
        # Sand Accuracy Down
        if [12,49].include?($fefieldeffect)
          if move.calcTypes.include?(:GROUND)
            @battle.pbDisplay(_INTL("The sand surrounded {1}!",target.pbThis(true)))
            target.pbLowerStatStage([:EVASION,:SPEED],1,nil,true)
          end
        end
        #-------------------------------------------------------------------------
        # ZUD - Grudge/Destiny Bond
        #-------------------------------------------------------------------------
        if defined?(Settings::ZUD_COMPAT)
          _ZUD_EffectsOnKO(move,user,target)
        else
          # Grudge
          if target.effects[PBEffects::Grudge] && target.fainted?
            move.pp = 0
            @battle.pbDisplay(_INTL("{1}'s {2} lost all of its PP due to the grudge!",
               user.pbThis,move.name))
          end
          # Destiny Bond (recording that it should apply)
          if target.effects[PBEffects::DestinyBond] && target.fainted?
            if user.effects[PBEffects::DestinyBondTarget]<0
              user.effects[PBEffects::DestinyBondTarget] = target.index
            end
          end
        end
        #-------------------------------------------------------------------------
      end
    end
  
    #=============================================================================
    # Effects after all hits (i.e. at end of move usage)
    #=============================================================================
    def pbEffectsAfterMove(user,targets,move,numHits)
      # Defrost
      if move.damagingMove?
        targets.each do |b|
          next if b.damageState.unaffected || b.damageState.substitute
          next if b.status != :FROZEN
          # NOTE: Non-Fire-type moves that thaw the user will also thaw the
          #       target (in Gen 6+).
          if move.calcTypes.include?(:FIRE) || (Settings::MECHANICS_GENERATION >= 6 && move.thawsUser?)
            b.pbCureStatus
          end
        end
      end
      # Destiny Bond
      # NOTE: Although Destiny Bond is similar to Grudge, they don't apply at
      #       the same time (although Destiny Bond does check whether it's going
      #       to trigger at the same time as Grudge).
      if user.effects[PBEffects::DestinyBondTarget]>=0 && !user.fainted?
        dbName = @battle.battlers[user.effects[PBEffects::DestinyBondTarget]].pbThis
        @battle.pbDisplay(_INTL("{1} took its attacker down with it!",dbName))
        user.pbReduceHP(user.hp,false)
        user.pbItemHPHealCheck
        user.pbFaint
        @battle.pbJudgeCheckpoint(user)
      end
      # User's ability
      #BattleHandlers.triggerUserAbilityEndOfMove(user.ability,user,targets,move,@battle)
      if !@battle.pbAllFainted?(user.idxOpposingSide)
        # Beast Boost
        if user.hasActiveAbility?(:BEASTBOOST) && $fefieldeffect != 29
          numFainted = 0
          targets.each { |b| numFainted += 1 if b.damageState.fainted }
          if numFainted > 0
            userStats = user.plainStats
            highestStatValue = 0
            userStats.each_value { |value| highestStatValue = value if highestStatValue < value }
            GameData::Stat.each_main_battle do |s|
              next if userStats[s.id] < highestStatValue
              numFainted *= 2 if [31,32,35,38].include?($fefieldeffect)
              user.pbRaiseStatStageByAbility(s.id,numFainted,user)
              break
            end
          end
        end
        # Moxie
        if user.hasActiveAbility?(:MOXIE) && $fefieldeffect != 12
          numFainted = 0
          targets.each { |b| numFainted += 1 if b.damageState.fainted }
          if numFainted > 0
            numFainted *= 2 if [6,45].include?($fefieldeffect)
            user.pbRaiseStatStageByAbility(:ATTACK,numFainted,user)
          end
        end
        # Chilling Neigh
        if user.hasActiveAbility?(:CHILLINGNEIGH) && ![7,12,16].include?($fefieldeffect)
          numFainted = 0
          targets.each { |b| numFainted += 1 if b.damageState.fainted }
          if numFainted > 0
            numFainted *= 2 if [13,28,46].include?($fefieldeffect)
            user.pbRaiseStatStageByAbility(:ATTACK,numFainted,user)
          end
        end
        # Grim Neigh
        if user.hasActiveAbility?(:GRIMNEIGH) && ![9,29].include?($fefieldeffect)
          numFainted = 0
          targets.each { |b| numFainted += 1 if b.damageState.fainted }
          if numFainted > 0
            numFainted *= 2 if $fefieldeffect == 40
            user.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,numFainted,user)
          end
        end
        # Necromancy
        if user.hasActiveAbility?(:NECROMANCY) && ![29,40,42].include?($fefieldeffect)
          numFainted = 0
          targets.each { |b| numFainted += 1 if b.damageState.fainted }
          if numFainted > 0
            numFainted *= 2 if [4,38].include?($fefieldeffect)
            user.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,numFainted,user)
          end
        end
        # Motivation
        if user.hasActiveAbility?(:MOTIVATION) && $fefieldeffect != 12
          faintedTarget = false
          targets.each { |b| 
            if b.damageState.fainted
              faintedTarget = true
              break
            end
          }
          if faintedTarget && @battle.pbSideSize(user.index + 1) > 1 # The user's opposing side has more than 1 spot
            if user.pbReducePP(move)
              if $fefieldeffect == 17
                user.pbRaiseStatStageByAbility(:ATTACK,1,user)
              end
              user.pbUseMoveSimple(move.id)
            end
          end
        end
        # Cautious
        if user.hasActiveAbility?(:CAUTIOUS) && $fefieldeffect != 39
          numFainted = 0
          targets.each { |b| numFainted += 1 if b.damageState.fainted }
          if numFainted > 0
            user.pbRaiseStatStageByAbility(:DEFENSE,numFainted,user)
          end
        end
        # Alphabetization
        if user.hasActiveAbility?(:ALPHABETIZATION)
          if user.checkAlphabetizationForm(15)
            numFainted = 0
            targets.each { |b| numFainted += 1 if b.damageState.fainted }
            for i in 0...numFainted
              stat = @battle.generateRandomStat
              if user.pbRaiseStatStageByCause(stat,12,user,nil)
                @battle.pbDisplay(_INTL("{1}'s {2} (Perform) maximized its {3}!",user.pbThis,user.abilityName,GameData::Stat.get(stat).name))
              end
              stat = @battle.generateRandomStat
              if user.pbRaiseStatStageByCause(stat,12,user,nil)
                @battle.pbDisplay(_INTL("{1}'s {2} (Perform) maximized its {3}!",user.pbThis,user.abilityName,GameData::Stat.get(stat).name))
              end
            end
          end
          if user.checkAlphabetizationForm(20)
            user.pbRecoverHP(user.totalhp) if user.canHeal?
            for i in user.moves
              user.pbSetPP(i,i.total_pp)
            end
            user.pbCureStatus(false)
            user.effects[PBEffects::Confusion] = 0
            @battle.pbDisplay(_INTL("{1}'s {2} (Undo) brought it back to perfect health!",user.pbThis,user.abilityName))
          end
        end
        # Time Rewind
        if user.hasActiveAbility?(:TIMEREWIND)
          targets.each { |b| 
            if b.damageState.fainted
              @battle.scene.pbRecall(user.index)
              @battle.pbDisplay(_INTL("{1}'s {2} brought it back to its previous state!",user.pbThis,user.abilityName))
              party = @battle.pbParty(user.index)
              idxPartyOld = user.pokemonIndex
              # Initialize the new Pokémon
              @battle.battlers[user.index].pbInitialize(@effects[PBEffects::TimeRewind],idxPartyOld,false)
              party[idxPartyOld] = @battle.battlers[user.index].pokemon
              # Send out the new Pokémon
              @battle.pbSendOut([[user.index,party[idxPartyOld]]])
              @battle.pbCalculatePriority(false,[user.index]) if Settings::RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES
              break
            end
          }
        end
        if user.canHeal?
          # Glutton
          if user.hasActiveAbility?(:GLUTTON) && move.bitingMove?
            faintedHP = 0
            targets.each { |b| faintedHP += b.totalhp if b.damageState.fainted }
            if faintedHP > 0
              user.pbRecoverHP(faintedHP)
            end
          end
          # Burst
          if user.hasActiveAbility?(:BURST) && move.bombMove? && move.calcTypes.include?(:FIRE)
            numFainted = 0
            targets.each { |b| numFainted += 1 if b.damageState.fainted }
            if numFainted > 0
              user.pbRecoverHP(user.totalhp * numFainted / 2)
            end
          end
        end
        # Fairy Tale Field - Barbarian/Bard/Cleric/Druid/Fighter/Monk/Sorcerer/Warlock/Wizard
        if $fefieldeffect == 31
          if move.physicalMove?
            numFainted = 0
            targets.each { |b| 
              next if !b.damageState.fainted
              if !user.effects[PBEffects::FairyTaleRoles].include?(0)
                user.effects[PBEffects::FairyTaleRoles].push(0)
                @battle.pbDisplay(_INTL("{1} was given the Barbarian role!",user.pbThis))
              else # First KO doesn't trigger
                numFainted += 1
              end
            }
            if numFainted > 0
              user.pbRaiseStatStageByCause([:ATTACK,:DEFENSE],numFainted,user,"Barbarian role")
            end
          end
          if move.soundMove?(user) && !user.effects[PBEffects::FairyTaleRoles].include?(1)
            user.effects[PBEffects::FairyTaleRoles].push(1)
            @battle.pbDisplay(_INTL("{1} was given the Bard role!",user.pbThis))
          end
          if move.healingMove? && !user.effects[PBEffects::FairyTaleRoles].include?(2) &&
             @battle.pbSideSize(user.index) > 1
            user.effects[PBEffects::FairyTaleRoles].push(2)
            @battle.pbDisplay(_INTL("{1} was given the Cleric role!",user.pbThis))
          end
          if [:BUG,:FAIRY,:FLYING,:GRASS,:GROUND,:WATER].include?(move.calcTypes[0]) && 
             user.lastMoveUsed != move.id && [:BUG,:FAIRY,:FLYING,:GRASS,:GROUND,:WATER].include?(user.lastMoveUsedType) &&
             !user.effects[PBEffects::FairyTaleRoles].include?(3)
            user.effects[PBEffects::FairyTaleRoles].push(3)
            @battle.pbDisplay(_INTL("{1} was given the Druid role!",user.pbThis))
          end
          if move.slashingMove? && !user.effects[PBEffects::FairyTaleRoles].include?(4)
            user.effects[PBEffects::FairyTaleRoles].push(4)
            @battle.pbDisplay(_INTL("{1} was given the Fighter role!",user.pbThis))
          end
          if (move.kickingMove? || move.punchingMove?) && !user.effects[PBEffects::FairyTaleRoles].include?(5) &&
             !user.hasRaisedStatStages?
            user.effects[PBEffects::FairyTaleRoles].push(5)
            @battle.pbDisplay(_INTL("{1} was given the Monk role!",user.pbThis))
          end
          targets.each { |b| 
            next if !b.damageState.fainted || !(b.pbHasType?(:DARK) || b.pbHasType?(:DRAGON) || 
                    b.pbHasType?(:GHOST) || b.pbHasType?(:POISON))
            if !user.effects[PBEffects::FairyTaleRoles].include?(6)
              user.effects[PBEffects::FairyTaleRoles].push(6)
              @battle.pbDisplay(_INTL("{1} was given the Paladin role!",user.pbThis))
            end
          }
          if move.specialMove? && (move.calcTypes.include?(user.type1) || move.calcTypes.include?(user.type2) ||
             move.calcTypes.include?(user.effects[PBEffects::Type3])) && !user.effects[PBEffects::FairyTaleRoles].include?(9)
            user.effects[PBEffects::FairyTaleRoles].push(9)
            @battle.pbDisplay(_INTL("{1} was given the Sorcerer role!",user.pbThis))
          end
          if [:DARK,:PSYCHIC,:GHOST,:POISON].include?(move.calcTypes[0]) && move.specialMove? &&
             user.lastMoveUsed != move.id && [:DARK,:PSYCHIC,:GHOST,:POISON].include?(user.lastMoveUsedType) && 
             GameData::Move.get(user.lastMoveUsed).special? && !user.effects[PBEffects::FairyTaleRoles].include?(10)
            user.effects[PBEffects::FairyTaleRoles].push(10)
            @battle.pbDisplay(_INTL("{1} was given the Warlock role!",user.pbThis))
          end
          if move.specialMove?
            targets.each { |b| 
              next if !b.damageState.fainted
              if !user.effects[PBEffects::FairyTaleRoles].include?(11)
                user.effects[PBEffects::FairyTaleRoles].push(11)
                @battle.pbDisplay(_INTL("{1} was given the Wizard role!",user.pbThis))
              end
            }
          end
          if move.specialMove?
            numFainted = 0
            targets.each { |b| 
              next if !b.damageState.fainted
              if !user.effects[PBEffects::FairyTaleRoles].include?(11)
                user.effects[PBEffects::FairyTaleRoles].push(11)
                @battle.pbDisplay(_INTL("{1} was given the Wizard role!",user.pbThis))
              else # First KO doesn't trigger
                numFainted += 1
              end
            }
            if numFainted > 0
              user.pbRaiseStatStageByCause([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],numFainted,user,"Wizard role")
            end
          end
        end
        # Starlight Arena - Leo
        if $fefieldeffect == 34 && [:BRAVE,:RASH].include?(user.pokemon.nature_id)
          numFainted = 0
          targets.each { |b| numFainted += 1 if b.damageState.fainted }
          if numFainted > 0
            userStats = user.plainStats
            highestStatValue = 0
            userStats.each_value { |value| highestStatValue = value if highestStatValue < value }
            GameData::Stat.each_main_battle do |s|
              next if userStats[s.id] < highestStatValue
              user.pbRaiseStatStageByAbility(s.id,numFainted,user)
              break
            end
          end
        end
        # Frozen Dimensional Field - Rage Moves
        if $fefieldeffect == 39 && move.rageMove?
          numFainted = 0
          targets.each { |b| numFainted += 1 if b.damageState.fainted }
          if numFainted > 0
            user.pbRaiseStatStageByAbility([:ATTACK,:SPECIAL_ATTACK],numFainted,user)
            user.pbRaiseCritRatio(numFainted,user)
          end
        end
        # Boxing Ring - Persistence
        if $fefieldeffect == 45 && !user.effects[PBEffects::Persistence]
          targets.each { |b| 
            if b.damageState.fainted
              user.effects[PBEffects::Persistence] = true
              break
            end
          }
        end
        # Hyper Beam + Glitch Field
        if user.effects[PBEffects::HyperBeam] > 0 && $fefieldeffect == 24
          targets.each { |b| 
            if b.damageState.fainted
              user.effects[PBEffects::HyperBeam] = 0
              break
            end
          }
        end
      end
      # Magician
      if user.hasActiveAbility?(:MAGICIAN) && !@battle.futureSight && move.pbDamagingMove? &&
         !user.item && !(battle.wildBattle? && user.opposes?)
        targets.each do |b|
          next if b.damageState.unaffected || b.damageState.substitute
          next if !b.item
          next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
          @battle.pbShowAbilitySplash(user)
          if b.hasStickyHold?
            @battle.pbShowAbilitySplash(b) if user.opposes?(b)
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",b.pbThis))
            end
            @battle.pbHideAbilitySplash(b) if user.opposes?(b)
            next
          end
          user.item = b.item
          b.item = nil
          b.activateUnburden
          if @battle.wildBattle? && !user.initialItem && b.initialItem==user.item
            user.setInitialItem(user.item)
            b.setInitialItem(nil)
          end
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,b.pbThis(true),user.itemName))
          else
            @battle.pbDisplay(_INTL("{1} stole {2}'s {3} with {4}!",user.pbThis,b.pbThis(true),user.itemName,user.abilityName))
          end
          @battle.pbHideAbilitySplash(user)
          user.pbHeldItemTriggerCheck
          break
        end
      end
      # Greninja - Battle Bond
      if !user.fainted? && !user.effects[PBEffects::Transform] && $fefieldeffect != 37 &&#user.isSpecies?(:GRENINJA) && 
         user.hasActiveAbility?(:BATTLEBOND,false,true)
        if !@battle.pbAllFainted?(user.idxOpposingSide) &&
           !@battle.battleBond[user.index&1][user.pokemonIndex]
          if $fefieldeffect == 31
            numFainted = 1
          else
            numFainted = 0
            targets.each { |b| numFainted += 1 if b.damageState.fainted }
          end
          if numFainted>0 && user.form==0 && user.pokemon.getNumForms > 0
            @battle.battleBond[user.index&1][user.pokemonIndex] = true
            @battle.pbDisplay(_INTL("{1} became fully charged due to its bond with its Trainer!",user.pbThis))
            @battle.pbShowAbilitySplash(user,true)
            @battle.pbHideAbilitySplash(user)
            user.pbChangeForm(1,_INTL("{1} became Ash-Greninja!",user.pbThis))
            if user.pbHasAnyStatus? && $fefieldeffect == 29
              @battle.pbDisplay(_INTL("The holy connection cured {1}'s status condition!",user.pbThis(true)))
              user.pbCureStatus(false)
            end
          end
        end
      end
      # Merciful Heart
      if user.hasActiveAbility?(:MERCIFULHEART) && move.statusMove? && ![32,39,40].include?($fefieldeffect)
        for b in targets
          if !b.opposes?(user) && !b.fainted?
            if [9,29,31].include?($fefieldeffect)
              b.pbRaiseStatStageByAbility(b.highestStat,2,user)
            else
              b.pbRaiseStatStageByAbility(b.highestStat,1,user)
            end
          end
        end
      end
      # Fairy Tale - Bard
      if $fefieldeffect == 31 && user.effects[PBEffects::FairyTaleRoles].include?(1) &&
         move.soundMove?(user)
        for b in targets
          next if b.fainted?
          if b.opposes?(user)
            b.pbLowerStatStageByCause([:DEFENSE,:SPECIAL_DEFENSE],1,user,"Bard role")
          else
            b.pbRaiseStatStageByCause([:ATTACK,:SPECIAL_ATTACK],1,user,"Bard role")
          end
        end
      end
      # Performer
      if user.hasActiveAbility?(:PERFORMER) && user.effects[PBEffects::Performer] > 0 && 
         user.canHeal?
        user.pbRecoverHP(user.effects[PBEffects::Performer])
        @battle.pbDisplay(_INTL("{1}'s {2} converted the leftover damage to health!",user.pbThis,user.abilityName))
      end
      # Dancer + Electric Terrain/Performance Stage
      if user.hasActiveAbility?(:DANCER) && move.danceMove?
        if $fefieldeffect == 1
          user.pbRaiseStatStageByAbility(:SPEED,1,user)
        elsif $fefieldeffect == 6
          user.pbRaiseStatStageByAbility([:SPECIAL_ATTACK,:SPEED],1,user)
        end
      end
      # Bodyguard
      if user.hasActiveAbility?(:BODYGUARD) && (move.pbDamagingMove? || [5,14,45].include?($fefieldeffect)) && 
         @battle.pbSideSize(user.index) > 1 && ![30,40,42].include?($fefieldeffect) && 
         user.effects[PBEffects::FollowMe] == 0
        @battle.pbDisplay(_INTL("{1} started guarding!",user.pbThis))
        user.effects[PBEffects::FollowMe]+=1
      end
      # Tap Dancing
      if user.hasActiveAbility?(:TAPDANCING) && move.danceMove?
        user.pbRaiseStatStageByAbility(:SPEED,1,user)
      end
      if move.calcTypes.include?(:BUG)
        # Light Geometry
        if @battle.pbCheckGlobalAbility(:LIGHTGEOMETRY)
          user.pbRaiseStatStageByAbility([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,@battle.pbCheckGlobalAbility(:LIGHTGEOMETRY))
        end
        # Insect Aroma
        if @battle.pbCheckGlobalAbility(:INSECTAROMA) && user.canHeal?
          user.pbRecoverHP(user.totalhp/4)
          @battle.pbDisplay(_INTL("{1}'s {2} healed {3}!",@battle.pbCheckGlobalAbility(:INSECTAROMA).pbThis,
                            @battle.pbCheckGlobalAbility(:INSECTAROMA).abilityName,user.pbThis(true)))
        end
      end
      # Mystical Gem
      if user.hasActiveAbility?(:MYSTICALGEM) && (move.calcTypes.include?(:PSYCHIC) ||
         $fefieldeffect == 4 && move.calcTypes.include?(:DARK) || $fefieldeffect == 25 &&
         move.calcTypes.include?(@battle.crystalType))
        user.pbRaiseStatStageByAbility([:SPECIAL_ATTACK,:SPEED],1,user)
      end
      # Power Trance
      if user.hasActiveAbility?(:POWERTRANCE) && move.calcTypes.include?(:PSYCHIC) &&
         !user.effects[PBEffects::PowerTrance]
        user.effects[PBEffects::PowerTrance] = true
        @battle.pbDisplay(_INTL("{1} entered a trance!",b.pbThis))
      end
      # Willpower
      directOpp = user.pbDirectOpposing(true)
      if user.hasActiveAbility?(:WILLPOWER) && targets.length == 1 && !targets[0].damageState.unaffected &&
         !user.opposes?(targets[0]) !directOpp.effects[PBEffects::Willpower]
        directOpp.effects[PBEffects::Willpower] = true
        @battle.pbDisplay(_INTL("{1}'s will was warped by {2}'s {3}!",directOpp.pbThis,user.pbThis(true),user.abilityName))
      end
      # User's Ally
      user.eachAlly do |b|
        if b.hasActiveAbility?(:ALPHABETIZATION) && b.checkAlphabetizationForm(9) && 
           !b.effects[PBEffects::TracedMove]
          b.effects[PBEffects::TracedMove] = true
          @battle.pbDisplay(_INTL("{1}'s {2} (Join) allowed it to join in with the attack!",b.pbThis,b.abilityName))
          b.pbUseMoveSimple(move.id)
        end
      end
      # Consume user's Gem
      if user.effects[PBEffects::GemConsumed]
        # NOTE: The consume animation and message for Gems are shown immediately
        #       after the move's animation, but the item is only consumed now.
        user.pbConsumeItem
      end
      # Field Effects
      case $fefieldeffect
      when 5 # Chess Board
        if [:MINDREADER,:FUTURESIGHT].include?(move.id)
          for b in targets
            b.effects[PBEffects::AlwaysMiss]=user.index
          end
        elsif move.id == :ROCKTOMB || move.id == :SANDTOMB || move.id == :EMBARGO || 
              move.id == :ATTACKORDER || move.id == :VCREATE || move.id == :THUNDERCAGE
          for b in targets
            b.effects[PBEffects::LockOn]=2
            b.effects[PBEffects::LockOnPos]=user.index
          end
          @battle.pbDisplay(_INTL("Checkmate!"))
        end
      when 8 # Swamp Field
        if user.stages[:SPEED]<0 && user.grounded? && [:FLY,:BOUNCE,:RAPIDSPIN,:GYROBALL,:TROPICALSHAKE].include?(move.id)
          user.stages[:SPEED]=0
          @battle.pbDisplay(_INTL("{1} extricated itself from the murk, resetting its Speed!",user.pbThis))
        end
      when 13 # Icy Cave
        if move.priority >= 1 && move.damagingMove? && move.pbContactMove?(user) || 
           move.danceMove? || [:LUNGE,:ROLLOUT,:DEFENSECURL,:STEAMROLLER,:ROLLINGKICK,
           :ICEBALL,:TAKEDOWN,:DOUBLEEDGE,:AGILITY,:DOUBLETEAM,:GYROBALL,:CLOSECOMBAT,
           :GIGAIMPACT,:HEADBUTT,:ZENHEADBUTT,:IRONHEAD,:HEADSMASH,:FLAMECHARGE,:HEADCHARGE,
           :AURAWHEEL,:ZINGZAP,:VOLTTACKLE,:TACKLE].include?(move.id)
          if user.grounded? && !user.pbOwnSide.effects[PBEffects::StickyWeb] && !user.hasActiveItem?(:HEAVYDUTYBOOTS) &&
             user.eachAlly.length > 0
            swapper = eachAlly[rand(eachAlly.length)]
            if @battle.pbSwapBattlers(user.index,swapper.index)
              @battle.pbDisplay(_INTL("{1} slid across the ice, swapping places with {2}!",user.pbThis,swapper.pbThis(true)))
              if Settings::MECHANICS_GENERATION >= 8
                @battle.pbActivateHealingWish(user)
                @battle.pbActivateHealingWish(swapper)
              end
            end
          end
        end
      when 17 # Factory Field
        if [:STEAMROLLER,:GEARGRIND,:GYROBALL,:ROLLINGKICK,:FLAMEWHEEL,:ROLLOUT,:RAPIDSPIN,
           :ICEBALL,:AURAWHEEL,:TRIPLEAXEL].include?(move.id)
          user.pbIncreaseStat(PBStats::SPEED,1,user,true)
          # Message played already for damage increase (and for stat increase)
        end
      when 19 # Wasteland
        if [:SEISMICTOSS,:SPLASH,:VITALTHROW,:SMACKDOWN].include?(move.id)
          for b in targets
            b.effects[PBEffects::WasteAnger]+=1
            @battle.pbDisplay(_INTL("{1} angered the waste!",b.pbThis))
          end
        elsif [:TORMENT,:TAUNT,:CURSE].include?(move.id)
          user.effects[PBEffects::WasteAnger]+=1
          @battle.pbDisplay(_INTL("{1} angered the waste!",user.pbThis))
        end
      when 31 # Fairy Tale Field
        for b in targets
          if [:DRAININGKISS,:SWEETKISS,:LOVELYKISS,:SWEETSCENT,:CAPTIVATE,:HEARTSTAMP].include?($fefieldeffect) && 
             b.pbCanAttract?(user,false)
            b.pbAttract(user)
          end
        end
      when 42 # Bewitched Woods
        for b in targets
          if (move.specialMove? && (move.calcTypes.include?(:PSYCHIC) || move.calcTypes.include?(:GHOST) ||
             move.calcTypes.include?(:DARK) || move.calcTypes.include?(:FAIRY)) || move.witchMove?) && 
             user.canBewitchedMark?
            user.effects[PBEffects::BewitchedMark] = true
            @battle.pbDisplay(_INTL("{1} was accused of witchcraft!",user.pbThis))
          elsif [:FORESIGHT,:MIRACLEEYE,:MINDREADER,:NIGHTMARE,:MEMENTO,:TRICK,:ROLEPLAY,
                :JUDGMENT,:SPOTLIGHT,:MAGICPOWDER].include?(move.id) && b.canBewitchedMark?
            b.effects[PBEffects::BewitchedMark] = true
            @battle.pbDisplay(_INTL("{1} was accused of witchcraft!",b.pbThis))
          end
        end
      end
      # Pokémon switching caused by Roar, Whirlwind, Circle Throw, Dragon Tail
      switchedBattlers = []
      move.pbSwitchOutTargetsEffect(user,targets,numHits,switchedBattlers)
      # Target's item, user's item, target's ability (all negated by Sheer Force)
      if move.addlEffect==0 || !user.hasActiveAbility?(:SHEERFORCE)
        pbEffectsAfterMove2(user,targets,move,numHits,switchedBattlers)
      end
      # Some move effects that need to happen here, i.e. U-turn/Volt Switch
      # switching, Baton Pass switching, Parting Shot switching, Relic Song's form
      # changing, Fling/Natural Gift consuming item.
      if !switchedBattlers.include?(user.index)
        move.pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
      end
      if numHits>0
        @battle.eachBattler { |b| b.pbItemEndOfMoveCheck }
      end
    end
  
    # Everything in this method is negated by Sheer Force.
    def pbEffectsAfterMove2(user,targets,move,numHits,switchedBattlers)
      hpNow = user.hp   # Intentionally determined now, before Shell Bell
      # Target's held item (Eject Button, Red Card)
      switchByItem = []
      @battle.pbPriority(true).each do |b|
        next if switchedBattlers.include?(b.index)
        next if !b.itemActive?
        next if switchByItem.length > 0 # Only one switch per move (Gen 8)
        next if switchedBattlers.length > 0 # Only one switch per move (Gen 8)
        if targets.any? { |targetB| targetB.index == b.index } # Eject Button, Red Card
          if !b.damageState.unaffected && b.damageState.calcDamage != 0
            BattleHandlers.triggerTargetItemAfterMoveUse(b.item,b,user,move,switchByItem,@battle)
          end
        end
        if b.effects[PBEffects::LashOut] # Eject Pack
          BattleHandlers.triggerItemOnStatLoss(b.item,b,user,move,switchByItem,@battle)
        end
      end
      @battle.moldBreaker = false if switchByItem.include?(user.index)
      @battle.pbPriority(true).each do |b|
        b.pbEffectsOnSwitchIn(true) if switchByItem.include?(b.index)
      end
      switchByItem.each { |idxB| switchedBattlers.push(idxB) }
      # User's held item (Life Orb, Shell Bell)
      if !switchedBattlers.include?(user.index) && user.itemActive?
        BattleHandlers.triggerUserItemAfterMoveUse(user.item,user,targets,move,numHits,@battle)
      end
      # Target's ability
      switchWimpOut = []
      @battle.pbPriority(true).each do |b|
        next if !targets.any? { |targetB| targetB.index==b.index }
        next if b.damageState.unaffected || switchedBattlers.include?(b.index)
        #BattleHandlers.triggerTargetAbilityAfterMoveUse(b.ability,b,user,move,switchedBattlers,@battle)
        if move.damagingMove?
          if b.damageState.initialHP >= b.totalhp/2 && b.hp < b.totalhp/2
            if b.hasActiveAbility?(:BERSERK)
              case $fefieldeffect
              when 5
                if b.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,b)
                  if b.pbLowerStatStageByCause(:ACCURACY,1,b,nil)
                    @battle.pbDisplay(_INTL("{1}'s rage made it lose concentration, decreasing its Accuracy!",b.pbThis))
                  end
                end
              when 29
                if b.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,b) && b.pbCanParalyze?(nil,false)
                  b.pbParalyze(nil,_INTL("{1} was punished for its anger, leaving it paralyzed!",b.pbThis))
                end
              when 32
                b.pbRaiseStatStageByAbility(:ATTACK,2,b)
              when 39
                b.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,2,b)
              when 45
                b.pbRaiseStatStageByAbility(:ATTACK,3,b)
              else
                b.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,b)
              end
            end
            if b.hasActiveAbility?(:REFORM) && !($fefieldeffect == 10 && b.grounded?)
              case $fefieldeffect
              when 3
                b.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,3,b)
              when 9,29
                b.pbRaiseStatStageByAbility([:SPECIAL_DEFENSE,:SPECIAL_ATTACK],1,b)
              when 20
                b.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,2,b)
              else
                b.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,b)
              end
              if $fefieldeffect == 8 && b.canHeal?
                b.pbRecoverHP(b.totalhp/5)
                @battle.pbDisplay(_INTL("{1} reformed as an even stronger swamp creature!",target.pbThis))
              elsif $fefieldeffect == 19
                b.pbRaiseStatStageByAbility(:DEFENSE,2,b)
              end
            end
            if b.hasActiveAbility?(:RECONSTRUCT) && $fefieldeffect != 24 && !([8,10].include?($fefieldeffect) &&
               b.grounded?)
              case $fefieldeffect
              when 17
                b.pbRaiseStatStageByAbility(:DEFENSE,2,b)
              else
                b.pbRaiseStatStageByAbility(:DEFENSE,1,b)
              end
              if $fefieldeffect == 5 && b.canHeal?
                b.pbRecoverHP(b.totalhp/5)
                @battle.pbDisplay(_INTL("{1} rebuilt a strong formation, restoring its HP!",target.pbThis))
              end
            end
            if b.hasActiveAbility?(:FRANTIC) && ![12,48].include?($fefieldeffect) &&
               !($fefieldeffect == 8 && b.grounded?)
              case $fefieldeffect
              when 1,18
                b.pbRaiseStatStageByAbility(:SPEED,2,b)
              else
                b.pbRaiseStatStageByAbility(:SPEED,1,b)
              end
              if [5,30].include?($fefieldeffect)
                b.pbLowerStatStageByAbility(:ACCURACY,1,b)
              end
            end
            if b.hasActiveAbility?(:SECONDWIND) && ![12,16,49].include?($fefieldeffect)
              if $fefieldeffect == 43
                amt = b.pbRecoverHP(b.totalhp/3)
              else
                amt = b.pbRecoverHP(b.totalhp/5)
              end
              if amt > 0
                @battle.pbDisplay(_INTL("{1}'s {2} restored some of its HP!",b.pbThis,b.abilityName))
                if $fefieldeffect == 6
                  if b.pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,b)
                    @battle.pbDisplay(_INTL("{1} prepares itself for another spectacle, boosting its Sp. Atk!",b.pbThis))
                  end
                elsif $fefieldeffect == 20
                  b.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,b)
                elsif $fefieldeffect == 45
                  b.pbRaiseStatStageByAbility(:ATTACK,1,b)
                end
              end
            end
            if b.hasActiveAbility?(:LIGHTING)
              b.effects[PBEffects::Charge] = 5
              @battle.pbAnimation(:CHARGE,b,nil)
              @battle.pbDisplay(_INTL("{1} began charging power!",b.pbThis))
            end
            if b.hasActiveAbility?(:KNOWLEDGE) && move.pp > 0
              mPP = move.pp
              move.pp = 0
              @battle.pbDisplay(_INTL("{1}'s {2} removed all of {3}'s {4}'s PP and shared it with its allies!",b.pbThis,b.abilityName,user.pbThis(true),move.name))
              keepSearching = mPP > 0
              while keepSearching
                keepSearching = false # Stays false if no more ally moves with less than max PP are found
                b.eachOwnSideBattler do |a|
                  for m in a.moves
                    if m.pp < m.total_pp
                      keepSearching = true
                      m.pp += 1
                      mPP -= 1
                    end
                    break if mPP == 0 # No more left to add
                  end
                end
              end
            end
          end
          if b.hasActiveAbility?(:STRONGWILL) && (b.damageState.initialHP >= b.totalhp/2 && 
             b.hp < b.totalhp/2 || $fefieldeffect == 29 && (move.calcTypes.include?(:DARK) ||
             move.calcTypes.include?(:GHOST))) && ![12,48,49].include?($fefieldeffect)
            b.pbRaiseStatStageByAbility(:ATTACK,1,b)
            if $fefieldeffect == 17
              b.pbRaiseCritRatio(1,b)
            end
          end
        end
        if b.hasActiveAbility?(:COLORCHANGE) && b.damageState.calcDamage > 0 && !b.damageState.substitute &&
           move.calcTypes
          pseudo=false
          for t in move.calcTypes
            pseudo=true if GameData::Type.get(t).pseudo_type
          end
          if !pseudo
            hasType=false
            for t in move.calcTypes
              hasType=true if b.pbHasType?(t) && !b.pbHasOtherType?(t)
            end
            if !hasType
              i=0
              typeName = ""
              while i<move.calcTypes.length
                if i == move.calcTypes.length-1 && move.calcTypes.length>1
                  typeName+="and "
                end
                typeName+=GameData::Type.get(move.calcTypes[i]).name
                if i < move.calcTypes.length-1
                  if move.calcTypes.length>2
                    typeName+=", "
                  elsif move.calcTypes.length>1
                    typeName+=" "
                  end
                end
                i+=1
              end
              b.pbChangeTypes(move.calcTypes,[9,25].include?($fefieldeffect)) # Only changes primary type when these fields
              @battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",b.pbThis,b.abilityName,typeName))
            end
          end
        end
        if b.hasActiveAbility?(:PICKPOCKET) && !(battle.wildBattle? && target.opposes?) &&
           move.contactMove? && !switchedBattlers.include?(user.index) && user.effects[PBEffects::Substitute] == 0 &&
           !b.damageState.substitute && !b.item && user.item && !user.unlosableItem?(user.item) &&
           !b.unlosableItem?(user.item)
          @battle.pbShowAbilitySplash(b)
          if user.hasStickyHold?
            @battle.pbShowAbilitySplash(user) if b.opposes?(user)
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",user.pbThis))
            end
            @battle.pbHideAbilitySplash(user) if b.opposes?(user)
            @battle.pbHideAbilitySplash(b)
          else
            b.item = user.item
            user.item = nil
            user.activateUnburden
            if @battle.wildBattle? && !b.initialItem && user.initialItem == b.item
              b.setInitialItem(b.item)
              user.setInitialItem(nil)
            end
            @battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",b.pbThis,user.pbThis(true),b.itemName))
            @battle.pbHideAbilitySplash(b)
            b.pbHeldItemTriggerCheck
          end
        end
        if b.hasActiveAbility?(:LEVIATHANSSLUMBER) && b.damageState.initialHP >= b.totalhp/4 && 
           b.hp < b.totalhp/4 && b.canHeal? && b.pbCanSleep?(b,false,nil,true) && 
           ![12,49].include?($fefieldeffect)
          b.pbSleepSelf(_INTL("{1} went into hibernation!",b.pbThis),3)
          if [21,22,23,32].include?($fefieldeffect)
            b.pbRecoverHP(b.totalhp)
          else
            b.pbRecoverHP(b.totalhp/2)
          end
          @battle.pbDisplay(_INTL("{1}'s HP was restored!",b.pbThis))
          if $fefieldeffect == 22
            b.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,3,b)
          elsif [31,32].include?($fefieldeffect)
            b.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,2,b)
          else
            b.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,b)
          end
        end
        if b.hasActiveAbility?(:BEHEMOTHSSLUMBER) && b.damageState.initialHP >= b.totalhp/4 && 
           b.hp < b.totalhp/4 && b.canHeal? && b.pbCanSleep?(b,false,nil,true) &&
           ![21,22,26].include?($fefieldeffect)
          b.pbSleepSelf(_INTL("{1} went into hibernation!",b.pbThis),3)
          if [7,16,23,32].include?($fefieldeffect)
            b.pbRecoverHP(b.totalhp)
          else
            b.pbRecoverHP(b.totalhp/2)
          end
          @battle.pbDisplay(_INTL("{1}'s HP was restored!",b.pbThis))
          if $fefieldeffect == 7
            b.pbRaiseStatStageByAbility(:DEFENSE,3,b)
          elsif [31,32].include?($fefieldeffect)
            b.pbRaiseStatStageByAbility(:DEFENSE,2,b)
          else
            b.pbRaiseStatStageByAbility(:DEFENSE,1,b)
          end
        end
        if !switchedBattlers.include?(b.index) && move.damagingMove?
          if b.pbAbilitiesOnDamageTaken(b.damageState.initialHP,-1,move.calcTypes)   # Emergency Exit, Wimp Out
            switchWimpOut.push(b.index)
          end
        end
      end
      @battle.moldBreaker = false if switchWimpOut.include?(user.index)
      @battle.pbPriority(true).each do |b|
        next if b.index==user.index
        b.pbEffectsOnSwitchIn(true) if switchWimpOut.include?(b.index)
      end
      switchWimpOut.each { |idxB| switchedBattlers.push(idxB) }
      # User's ability (Emergency Exit, Wimp Out)
      if !switchedBattlers.include?(user.index) && move.damagingMove?
        hpNow = user.hp if user.hp<hpNow   # In case HP was lost because of Life Orb
        if user.pbAbilitiesOnDamageTaken(user.initialHP,hpNow)
          @battle.moldBreaker = false
          user.pbEffectsOnSwitchIn(true)
          switchedBattlers.push(user.index)
        end
      end
    end
  end
  