class PokeBattle_AI
    #=============================================================================
    # Get a score for the given move based on its effect. Takes function input to
    # allow for recursive method calls for compound scores. extraParam is used as
    # a parameter for certain "pseudofunctions". If effectChance is left at -1, it
    # will find the chance based on the input callMove.
    #=============================================================================
    def pbGetMoveScoreFunctionCode(function,callMove,realMove,user,target,damage,effectChance=callMove.addlEffect,extraParam=nil)
      effectScore = 0.0
      case function
      #---------------------------------------------------------------------------
      when "000" # Tackle
      #---------------------------------------------------------------------------
      when "001" # Splash
        if [21,26,48].include?($fefieldeffect)
          user.eachNearOpposing do |b|
            effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:FLASH),callMove,
                           realMove,user,b,damage)
            if $fefieldeffect == 26
              effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:POISONPOWDER),
                             callMove,realMove,user,b,damage)
            end
          end
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (001): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "003" # Relic Song, Hypnosis
        if target.pbCanSleep?(user,false,callMove) && (target.effects[PBEffects::Substitute] == 0 || 
           callMove.ignoresSubstitute?(user)) && checkEffect?(callMove,realMove,user,target,damage)
          effectScore = (user.opposes?(target)) ? 55.0 : -55.0
          echo("\n[AI - #{Time.now - $time}] Effect score for sleep move starts at #{effectScore} because #{target.pbThis(true)} can be put to sleep.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          effectScore = sleepCode(effectScore,callMove,realMove,user,target,damage)
          if target.shouldMoveAfter?(user,realMove)
            effectScore *= 1.3
            echo("\n[AI - #{Time.now - $time}] Effect score x1.3 because #{user.pbThis(true)} should go before #{target.pbThis(true)}. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
          echo("\n[AI - #{Time.now - $time}] Final effect score (003): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        else
          echo("\n[AI - #{Time.now - $time}] Effect score (003) is 0 because #{target.pbThis(true)} won't be put to sleep by #{callMove.name}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
      #---------------------------------------------------------------------------
      when "004" # Yawn
        if target.pbCanSleepYawn? && target.effects[PBEffects::Yawn] == 0 && (target.effects[PBEffects::Substitute] == 0 || 
           callMove.ignoresSubstitute?(user)) && checkEffect?(callMove,realMove,user,target,damage)
          effectScore = (user.opposes?(target)) ? 25.0 : -25.0
          echo("\n[AI - #{Time.now - $time}] Effect score for sleep move starts at #{effectScore} because #{target.pbThis(true)} can be put to sleep.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          effectScore = sleepCode(effectScore,callMove,realMove,user,target,damage)
          if !@battle.pbCanSwitch?(target.index)
            effectScore *= 1.5
            echo("\n[AI - #{Time.now - $time}] Effect score x1.5 because #{target.pbThis(true)} is trapped. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
          echo("\n[AI - #{Time.now - $time}] Final effect score (004): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        else
          echo("\n[AI - #{Time.now - $time}] Effect score (004) is 0 because #{target.pbThis(true)} won't be put to sleep by #{callMove.name}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
      #---------------------------------------------------------------------------
      when "005" # Sludge Bomb, Poison Gas
        if $fefieldeffect == 11 && target.affectedByCorrosiveMist?
          echo("\n[AI - #{Time.now - $time}] Effect score (005) is 0 because #{target.pbThis(true)} will be poisoned anyway at the end of the round.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        else
          if $fefieldeffect == 24
            effectScore = (user.opposes?(target)) ? 15.0 : -15.0
          else
            effectScore = (user.opposes?(target)) ? 20.0 : -20.0
          end
          if target.hasActiveAbility?(:SYNCHRONIZE) && !user.hasActiveAbility?(:SYNCHRONIZE)
            synchroScore = pbGetMoveScoreFunctionCode(getFunctionCode(:SLUDGEBOMB),callMove,realMove,
                           target,user,0,effectChance)
            effectScore -= synchroScore
            echo("\n[AI - #{Time.now - $time}] Effect score -#{synchroScore} because #{target.pbThis(true)} has Synchronize. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          effectScore = poisonCode(effectScore,callMove,realMove,user,target,damage)
          effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
          echo("\n[AI - #{Time.now - $time}] Final effect score (005): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
      #---------------------------------------------------------------------------
      when "006" # Poison Fang, Toxic
        if $fefieldeffect == 11 && target.affectedByCorrosiveMist?
          if target.hasActiveAbility?([:WATERVEIL,:WATERABSORB,:RAINDISH,:WATERBUBBLE])
            echo("\n[AI - #{Time.now - $time}] Effect score (006) is 0 because #{target.pbThis(true)} will be badly poisoned anyway at the end of the round.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            return 0
          else
            effectScore = (user.opposes?(target)) ? 25.0 : -25.0 # Difference in badly vs normal poison
          end
        elsif $fefieldeffect == 19
          return pbGetMoveScoreFunctionCode(getFunctionCode(:SLUDGEBOMB),callMove,realMove,
                 user,target,damage,effectChance) # Can only inflict regular poison as a random status
        else
          effectScore = (user.opposes?(target)) ? 45.0 : -45.0
        end
        if target.hasActiveAbility?(:SYNCHRONIZE) && !user.hasActiveAbility?(:SYNCHRONIZE)
          synchroScore = pbGetMoveScoreFunctionCode(getFunctionCode(:POISONFANG),callMove,realMove,
                         target,user,0,effectChance)
          effectScore -= synchroScore
          echo("\n[AI - #{Time.now - $time}] Effect score -#{synchroScore} because #{target.pbThis(true)} has Synchronize. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
        effectScore = poisonCode(effectScore,callMove,realMove,user,target,damage)
        if target.hasKnownHealingMove?
          effectScore *= 2
          echo("\n[AI - #{Time.now - $time}] Effect score x2 because #{target.pbThis(true)} has a healing move. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (006): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "007" # Thunderbolt, Thunder Wave
        if target.pbCanParalyze?(user,false,callMove) && (target.effects[PBEffects::Substitute] == 0 || 
           callMove.ignoresSubstitute?(user)) && checkEffect?(callMove,realMove,user,target,damage)
          effectScore = (user.opposes?(target)) ? 40.0 : -40.0
          if target.hasActiveAbility?(:MARVELSCALE)
            marvelMult = pbGetMoveScoreFunctionCode("TargetMarvelScale",callMove,realMove,
                         user,target,damage,0)
            effectScore += marvelMult
            echo("\n[AI - #{Time.now - $time}] Effect score +#{marvelMult} because #{target.pbThis(true)} has Marvel Scale. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.hasActiveAbility?(:GUTS)
            gutsMult = pbGetMoveScoreFunctionCode("TargetGuts",callMove,realMove,
                       user,target,damage,0)
            effectScore += gutsMult
            echo("\n[AI - #{Time.now - $time}] Effect score +#{gutsMult} because #{target.pbThis(true)} has Guts. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.hasActiveAbility?(:QUICKFEET)
            quickMult = pbGetMoveScoreFunctionCode("TargetQuickFeet",callMove,realMove,
                        user,target,damage,0)
            effectScore += quickMult
            echo("\n[AI - #{Time.now - $time}] Effect score +#{quickMult} because #{target.pbThis(true)} has Quick Feet. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          erScore = endOfRoundScore(user,target)
          effectScore += 0.2 * erScore
          echo("\n[AI - #{Time.now - $time}] Effect score +#{0.2*erScore} due to the end-of-round effects that will occur to #{target.pbThis(true)} while it can't move. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          if user.opposes?(target)
            user.eachOwnSideBattler do |b|
              # Doesn't take into account being immune to these moves
              if b.hasKnownMoveFunction?(:HEX) && $fefieldeffect != 40
                effectScore *= 1.3
                echo("\n[AI - #{Time.now - $time}] Effect score x1.3 because #{b.pbThis(true)} has Hex. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              end
              if b.hasKnownMoveFunction?(:SMELLINGSALTS) && [11,22].include?($fefieldeffect)
                effectScore *= 1.1
                echo("\n[AI - #{Time.now - $time}] Effect score x1.1 because #{b.pbThis(true)} has Smelling Salts. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              end
              if target.takesIndirectDamage?
                if b.hasActiveAbility?(:PAININGPARALYSIS) && ![9,48].include?($fefieldeffect)
                  if $fefieldeffect == 1
                    effectScore *= 1.7
                    echo("\n[AI - #{Time.now - $time}] Effect score x1.7 because #{b.pbThis(true)} has Paining Paralysis (which deals more damage under Electric Terrain) and #{target.pbThis(true)} can be damaged by it. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                  else
                    effectScore *= 1.5
                    echo("\n[AI - #{Time.now - $time}] Effect score x1.5 because #{b.pbThis(true)} has Paining Paralysis and #{target.pbThis(true)} can be damaged by it. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                  end
                end
              end
              setupMult = runSetupMoves(b,1.1)
              effectScore *= setupMult
              echo("\n[AI - #{Time.now - $time}] Effect score x#{setupMult} due to #{b.pbThis(true)}'s setup moves. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              if b.effects[PBEffects::Substitute] > 0 # Will still have Substitute up
                effectScore *= 1.2
                echo("\n[AI - #{Time.now - $time}] Effect score x1.2 because #{b.pbThis(true)} has a Substitute up. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              elsif b.hasKnownMoveFunction?(:SUBSTITUTE)
                effectScore *= 1.1
                echo("\n[AI - #{Time.now - $time}] Effect score x1.1 because #{b.pbThis(true)} has Substitute. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              end
            end
          end
          statMult = statChangeMult(target,1.2,false,true)
          effectScore *= statMult
          echo("\n[AI - #{Time.now - $time}] Effect score x#{statMult} due to #{target.pbThis(true)}'s offensive stat changes. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          if target.hasActiveAbility?(:NATURALCURE) && @battle.pbCanSwitch?(target.index)
            effectScore *= 0.3
            echo("\n[AI - #{Time.now - $time}] Effect score x0.3 because #{target.pbThis(true)} has Natural Cure and can switch out. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.hasKnownMoveFunction?(:FACADE)
            effectScore *= 0.4
            echo("\n[AI - #{Time.now - $time}] Effect score x0.4 because #{target.pbThis(true)} has revealed Facade. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.hasKnownMoveFunction?(:REST)
            effectScore *= 0.4
            echo("\n[AI - #{Time.now - $time}] Effect score x0.4 because #{target.pbThis(true)} has revealed Rest. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.effects[PBEffects::Confusion] > 0
            effectScore *= 1.1
            echo("\n[AI - #{Time.now - $time}] Effect score x1.1 because #{target.pbThis(true)} is confused. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.effects[PBEffects::Attract] >= 0
            effectScore *= 1.1
            echo("\n[AI - #{Time.now - $time}] Effect score x1.1 because #{target.pbThis(true)} is infatuated. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.hasActiveAbility?(:SHEDSKIN)
            effectScore *= 0.7
            echo("\n[AI - #{Time.now - $time}] Effect score x0.7 because #{target.pbThis(true)} has Shed Skin. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.hasActiveAbility?(:HYDRATION) && [:Rain,:HeavyRain].include?(@battle.pbWeather) ||
             target.hasActiveAbility?(:NATURALCURE) && ([2,15,31,42].include?($fefieldeffect) ||
             $fefieldeffect == 33 && $fecounter >= 2)
            effectScore *= 0.1
            echo("\n[AI - #{Time.now - $time}] Effect score x0.1 because #{target.pbThis(true)}'s sleep will be cured at the end of the round. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if !target.hasActiveAbility?(:QUICKFEET)
            tSpeed = target.pbSpeed
            numNearOpp = target.numNearOpposing
            target.eachNearOpposing do |b|
              uSpeed = b.pbSpeed
              if uSpeed < tSpeed && (uSpeed > tSpeed * 0.5 || $fefieldeffect == 24 && 
                 uSpeed > tSpeed * 0.25)
                effectScore *= 1.5 / numNearOpp
                echo("\n[AI - #{Time.now - $time}] Effect score x#{1.5/numNearOpp} because #{b.pbThis(true)} will become faster than #{target.pbThis(true)}. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              end
            end
          end
          if $fefieldeffect == 18 && target.affectedByShortCircuit?
            effectScore *= 0.8
            echo("\n[AI - #{Time.now - $time}] Effect score x0.7 because #{target.pbThis(true)} might become paralyzed at the end of the round anyway. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.effects[PBEffects::Yawn] > 0 # Falls asleep at end of round
            yawnScore = pbGetMoveScoreFunctionCode(getFunctionCode(:HYPNOSIS),callMove,alwaysLastMove,
                        user,target,damage,effectChance)
            effectScore -= yawnScore
            echo("\n[AI - #{Time.now - $time}] Effect score -#{yawnScore} because #{target.pbThis(true)} is affected by Yawn. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
          echo("\n[AI - #{Time.now - $time}] Final effect score (007): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        else
          echo("\n[AI - #{Time.now - $time}] Effect score (007) is 0 because #{target.pbThis(true)} won't be paralyzed by #{callMove.name}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
      #---------------------------------------------------------------------------
      when "008" # Thunder
        return pbGetMoveScoreFunctionCode(getFunctionCode(:THUNDERBOLT),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "009" # Thunder Fang
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:THUNDERBOLT),callMove,realMove,
                       user,target,damage,0.1*effectChance)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:IRONHEAD),callMove,realMove,
                       user,target,damage,0.1*effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (009): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "00A" # Flamethrower, Will-O-Wisp
        effectScore = 0.0 #(user.opposes?(target)) ? 35.0 : -35.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (00A): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "00B" # Fire Fang
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:FLAMETHROWER),callMove,realMove,
                       user,target,damage,0.1*effectChance)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:IRONHEAD),callMove,realMove,
                       user,target,damage,0.1*effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (00B): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "00C" # Ice Beam
        effectScore = 0.0 #(user.opposes?(target)) ? 70.0 : -70.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (00C): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "00D" # Blizzard
        return pbGetMoveScoreFunctionCode(getFunctionCode(:ICEBEAM),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "00E" # Ice Fang
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:ICEBEAM),callMove,realMove,
                       user,target,damage,0.1*effectChance)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:IRONHEAD),callMove,realMove,
                       user,target,damage,0.1*effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (00E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "00F" # Iron Head
        effectScore = 0.0 #(user.opposes?(target)) ? 40.0 : -40.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (00F): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "010" # Stomp
        return pbGetMoveScoreFunctionCode(getFunctionCode(:IRONHEAD),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "011" # Snore
        # Fail check already accounted for
        return pbGetMoveScoreFunctionCode(getFunctionCode(:IRONHEAD),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "012" # Fake Out
        # Fail check already accounted for
        return pbGetMoveScoreFunctionCode(getFunctionCode(:IRONHEAD),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "013" # Confusion, Confuse Ray
        effectScore = 0.0 #(user.opposes?(target)) ? 30.0 : -30.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (013): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "014" # Chatter
        return pbGetMoveScoreFunctionCode(getFunctionCode(:CONFUSION),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "015" # Hurricane
        return pbGetMoveScoreFunctionCode(getFunctionCode(:CONFUSION),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "016" # Attract
        effectScore = 0.0 #(user.opposes?(target)) ? 30.0 : -30.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (016): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "017" # Tri Attack
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:ICEBEAM),callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:FLAMETHROWER),callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:THUNDERBOLT),callMove,realMove,
                       user,target,damage,effectChance)
        effectScore /= 3 # Average of all possibilities (don't input effectChance/3 because can mess with Serene Grace and etc.)
        echo("\n[AI - #{Time.now - $time}] Final effect score (017): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "018" # Refresh
        effectScore += pbGetMoveScoreFunctionCode("UserBurnCure",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserParalysisCure",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserPoisonCure",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (018): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "019" # Aromatherapy
        effectScore = 0.0 #40.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (019): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "01A" # Safeguard
        effectScore = 0.0 #5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (01A): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "01B" # Psycho Shift
        effectScore = 0.0 #(user.opposes?(target)) ? 30.0 : -30.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (01B): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      # \/ ACCOUNT FOR GETSTATUP AND GETSTATDOWN \/
      when "01C" # Power-Up Punch, Sharpen
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "01D" # Steel Wing, Harden
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (01D): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "01E" # Defense Curl
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        # Add score for curling up
        echo("\n[AI - #{Time.now - $time}] Final effect score (01E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "01F" # Flame Charge
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (01F): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "020" # Charge Beam
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (020): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "021" # Charge
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        # Add score for Electric move boost
        echo("\n[AI - #{Time.now - $time}] Final effect score (021): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "022" # Double Team
        effectScore += pbGetMoveScoreFunctionCode("UserEvasionUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (022): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "023" # Focus Energy
        # Add check to make sure not already affected by Focus Energy
        effectScore += pbGetMoveScoreFunctionCode("UserCritUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (023): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "024" # Bulk Up
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (024): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "025" # Coil
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserAccuracyUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (025): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "026" # Dragon Dance
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (026): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "027" # Work Up
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (027): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "028" # Growth
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (028): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "029" # Hone Claws
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserAccuracyUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (029): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "02A" # Cosmic Power
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (02A): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "02B" # Quiver Dance
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (02B): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "02C" # Calm Mind
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (02C): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "02D" # Ancient Power
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (02D): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "02E" # Swords Dance
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (02E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "02F" # Iron Defense
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (02F): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "030" # Agility
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (030): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "031" # Autotomize
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        # Add weight reduction score
        echo("\n[AI - #{Time.now - $time}] Final effect score (031): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "032" # Nasty Plot
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (032): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "033" # Amnesia
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (033): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "034" # Minimize
        effectScore += pbGetMoveScoreFunctionCode("UserEvasionUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (034): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "035" # Shell Smash
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (035): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "036" # Shift Gear
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (036): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "037" # Acupressure
        effectScore += pbGetMoveScoreFunctionCode("TargetAttackUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("TargetDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("TargetSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("TargetSpDefUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("TargetSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("TargetAccuracyUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("TargetEvasionUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore /= 7
        echo("\n[AI - #{Time.now - $time}] Final effect score (037): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "038" # Cotton Guard
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,3)
        echo("\n[AI - #{Time.now - $time}] Final effect score (038): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "039" # Tail Glow
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,3)
        echo("\n[AI - #{Time.now - $time}] Final effect score (039): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "03A" # Belly Drum
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,12)
        effectScore += pbGetMoveScoreFunctionCode("UserDamage",callMove,realMove,
                       user,target,damage,effectChance,[user.totalhp/2,1].max)
        echo("\n[AI - #{Time.now - $time}] Final effect score (03A): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "03B" # Superpower
        effectScore += pbGetMoveScoreFunctionCode("UserAttackDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (03B): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "03C" # Close Combat
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (03C): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "03D" # V-Create
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (03D): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "03E" # Hammer Arm
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (03E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "03F" # Overheat
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkDown",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (03F): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "040" # Flatter
        effectScore += pbGetMoveScoreFunctionCode("TargetSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:CONFUSERAY),callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (040): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "041" # Swagger
        # Probably want to make it so the confusion score takes into account Attack increase
        effectScore += pbGetMoveScoreFunctionCode("TargetAttackUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:CONFUSERAY),callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (041): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "042" # Growl, Trop Kick
        effectScore += pbGetMoveScoreFunctionCode("TargetAttackDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (042): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "043" # Tail Whip
        effectScore += pbGetMoveScoreFunctionCode("TargetDefenseDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (043): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "044" # Bulldoze
        effectScore += pbGetMoveScoreFunctionCode("TargetSpeedDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (044): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "045" # Moonblast, Confide
        effectScore += pbGetMoveScoreFunctionCode("TargetSpAtkDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (045): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "046" # Bug Buzz
        effectScore += pbGetMoveScoreFunctionCode("TargetSpDefDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (046): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "047" # Smokescreen, Mud-Slap
        effectScore += pbGetMoveScoreFunctionCode("TargetAccuracyDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (047): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "048" # Sweet Scent
        effectScore += pbGetMoveScoreFunctionCode("TargetEvasionDown",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (048): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "049" # Defog
        effectScore += pbGetMoveScoreFunctionCode("TargetEvasionDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        # Add hazard-clearing score
        echo("\n[AI - #{Time.now - $time}] Final effect score (049): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "04A" # Tickle
        effectScore += pbGetMoveScoreFunctionCode("TargetAttackDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("TargetDefenseDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (04A): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "04B" # Charm
        effectScore += pbGetMoveScoreFunctionCode("TargetAttackDown",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (04B): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "04C" # Screech
        effectScore += pbGetMoveScoreFunctionCode("TargetDefenseDown",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (04C): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "04D" # Scary Face
        effectScore += pbGetMoveScoreFunctionCode("TargetSpeedDown",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (04D): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "04E" # Captivate
        # Add gender check
        effectScore += pbGetMoveScoreFunctionCode("TargetSpAtkDown",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (04E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "04F" # Metal Sound
        effectScore += pbGetMoveScoreFunctionCode("TargetSpDefDown",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (04F): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "050" # Clear Smog
        effectScore = 0.0 #10
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (050): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "051" # Haze
        effectScore = 0.0 #10
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (051): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "052" # Power Swap
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (052): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "053" # Guard Swap
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (053): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "054" # Heart Swap
        effectScore = 0.0 #20
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (054): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "055" # Psych Up
        effectScore = 0.0 #10
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (055): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "056" # Mist
        effectScore = 0.0 #20
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (056): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "057" # Power Trick
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (057): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "058" # Power Split
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (058): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "059" # Guard Split
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (059): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "05A" # Pain Split
        effectScore = 0.0 #30
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (05A): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "05B" # Tailwind
        effectScore = 0.0 #35
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score: (05B) #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "05C" # Mimic
        effectScore = 0.0 #15
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (05C): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "05D" # Sketch
        effectScore = 0.0 #15
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (05D): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "05E" # Conversion
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (05E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "05F" # Conversion 2
        effectScore = 0.0 #20
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (05F): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "060" # Camouflage
        effectScore = 0.0 #10
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (060): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "061" # Soak
        effectScore = 0.0 #30
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (061): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "062" # Reflect Type
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (062): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "063" # Simple Beam
        effectScore = 0.0 #20
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (063): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "064" # Worry Seed
        effectScore = 0.0 #20
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (064): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "065" # Role Play
        effectScore = 0.0 #15
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (065): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "066" # Entrainment
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (066): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "067" # Skill Swap
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (067): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "068" # Gastro Acid
        effectScore = 0.0 #20
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (068): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "069" # Transform
        effectScore = 0.0 #20
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (069): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "06A" # Sonic Boom
      #---------------------------------------------------------------------------
      when "06B" # Dragon Rage
      #---------------------------------------------------------------------------
      when "06C" # Super Fang
      #---------------------------------------------------------------------------
      when "06D" # Seismic Toss
      #---------------------------------------------------------------------------
      when "06E" # Endeavor
      #---------------------------------------------------------------------------
      when "06F" # Psywave
      #---------------------------------------------------------------------------
      when "070" # Fissure
      #---------------------------------------------------------------------------
      when "071" # Counter
      #---------------------------------------------------------------------------
      when "072" # Mirror Coat
      #---------------------------------------------------------------------------
      when "073" # Metal Burst
      #---------------------------------------------------------------------------
      when "074" # Flame Burst
        effectScore = 0.0 #(user.opposes?(target)) ? 5.0 : -5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (074): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "075" # Surf
      #---------------------------------------------------------------------------
      when "076" # Earthquake
      #---------------------------------------------------------------------------
      when "077" # Gust
      #---------------------------------------------------------------------------
      when "078" # Twister
        return pbGetMoveScoreFunctionCode(getFunctionCode(:IRONHEAD),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "079" # Fusion Bolt
      #---------------------------------------------------------------------------
      when "07A" # Fusion Flare
      #---------------------------------------------------------------------------
      when "07B" # Venoshock
      #---------------------------------------------------------------------------
      when "07C" # Smelling Salts
        return pbGetMoveScoreFunctionCode("targetParalysisCure",callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "07D" # Wake-Up Slap
        return pbGetMoveScoreFunctionCode("targetSleepCure",callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "07E" # Facade
      #---------------------------------------------------------------------------
      when "07F" # Hex
      #---------------------------------------------------------------------------
      when "080" # Brine
      #---------------------------------------------------------------------------
      when "081" # Avalanche
      #---------------------------------------------------------------------------
      when "082" # Assurance
      #---------------------------------------------------------------------------
      when "083" # Round - make score for priority order change
      #---------------------------------------------------------------------------
      when "084" # Payback
      #---------------------------------------------------------------------------
      when "085" # Retaliate
      #---------------------------------------------------------------------------
      when "086" # Acrobatics
      #---------------------------------------------------------------------------
      when "087" # Weather Ball
      #---------------------------------------------------------------------------
      when "088" # Pursuit - make score for priority order change
      #---------------------------------------------------------------------------
      when "089" # Return
      #---------------------------------------------------------------------------
      when "08A" # Frustration
      #---------------------------------------------------------------------------
      when "08B" # Eruption
      #---------------------------------------------------------------------------
      when "08C" # Wring Out
      #---------------------------------------------------------------------------
      when "08D" # Gyro Ball
      #---------------------------------------------------------------------------
      when "08E" # Stored Power
      #---------------------------------------------------------------------------
      when "08F" # Punishment
      #---------------------------------------------------------------------------
      when "090" # Hidden Power
      #---------------------------------------------------------------------------
      when "091" # Fury Cutter
        effectScore = 0.0 #10.0 # Score for setting up next higher damage
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (091): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "092" # Echoed Voice
      #---------------------------------------------------------------------------
      when "093" # Rage
      #---------------------------------------------------------------------------
      when "094" # Present
      #---------------------------------------------------------------------------
      when "095" # Magnitude
      #---------------------------------------------------------------------------
      when "096" # Natural Gift
        # Fail check already accounted for
        effectScore = 0.0 #-10 # Score for destroying berry
        # No effect chance modifier because always occurs
        echo("\n[AI - #{Time.now - $time}] Final effect score (096): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "097" # Trump Card
      #---------------------------------------------------------------------------
      when "098" # Flail
      #---------------------------------------------------------------------------
      when "099" # Electro Ball
      #---------------------------------------------------------------------------
      when "09A" # Grass Knot
      #---------------------------------------------------------------------------
      when "09B" # Heavy Slam
      #---------------------------------------------------------------------------
      when "09C" # Helping Hand
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (09C): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "09D" # Mud Sport
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (09D): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "09E" # Water Sport
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (09E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "09F" # Judgment, Multi-Attack, Techno Blast
      #---------------------------------------------------------------------------
      when "0A0" # Frost Breath
      #---------------------------------------------------------------------------
      when "0A1" # Lucky Chant
        effectScore = 0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0A1): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0A2" # Reflect
        effectScore = 0.0 #35
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0A2): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0A3" # Light Screen
        effectScore = 0.0 #35
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0A3): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0A4" # Secret Power
        case $fefieldeffect
        when 31,42 # Fairy Tale Field, Bewitched Woods
          return pbGetMoveScoreFunctionCode(getFunctionCode(:HYPNOSIS),callMove,realMove,
                 user,target,damage,effectChance)
        when 7 # Volcanic Field
          return pbGetMoveScoreFunctionCode(getFunctionCode(:WILLOWISP),callMove,realMove,
                 user,target,damage,effectChance)
        when 1,18 # Electric Terrain, Short-Circuit Field
          return pbGetMoveScoreFunctionCode(getFunctionCode(:THUNDERWAVE),callMove,realMove,
                 user,target,damage,effectChance)
        when 28,39 # Snowy Mountain, Frozen Dimensional Field
          return pbGetMoveScoreFunctionCode(getFunctionCode(:ICEBEAM),callMove,realMove,
                 user,target,damage,effectChance)
        when 26 # Murkwater Surface
          return pbGetMoveScoreFunctionCode(getFunctionCode(:POISONGAS),callMove,realMove,
                 user,target,damage,effectChance)
        when 12,49 # Desert, Xeric Shrubland
          return pbGetMoveScoreFunctionCode("TargetAttackDown",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 10 # Corrosive Field
          return pbGetMoveScoreFunctionCode("TargetDefenseDown",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 29 # Holy Field
          return pbGetMoveScoreFunctionCode("TargetSpAtkDown",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 35,38,41 # New World, Dimensional Field, Corrupted Cave
          return pbGetMoveScoreFunctionCode("TargetSpDefDown",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 8,46 # Swamp, Subzero Field
          return pbGetMoveScoreFunctionCode("TargetSpeedDown",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 4,16 # Dark Crystal Cavern, Volcanic Top Field
          return pbGetMoveScoreFunctionCode("TargetAccuracyDown",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 22,34 # Underwater, Starlight Arena
          return pbGetMoveScoreFunctionCode("TargetEvasionDown",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 20,45,47 # Ashen Beach, Boxing Ring, Jungle
          return pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 15,23 # Forest Field, Cave
          return pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 2,25,33 # Grassy Terrain, Crystal Cavern, Flower Garden Field
          return pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 3,11,48 # Misty Terrain, Corrosive Mist Field, Beach
          return pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 13,17,21,43 # Icy Cave, Factory Field, Water Surface, Sky Field
          return pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 6 # Performance Stage
          return pbGetMoveScoreFunctionCode("UserAccuracyUp",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 30,40 # Mirror Arena, Haunted Field
          return pbGetMoveScoreFunctionCode("UserEvasionUp",callMove,realMove,
                 user,target,damage,effectChance,1)
        when 5,14,27,32,44 # Chess Board, Rocky Field, Mountain, Dragon's Den, Indoors
          return pbGetMoveScoreFunctionCode(getFunctionCode(:IRONHEAD),callMove,realMove,
                 user,target,damage,effectChance)
        when 24,36,37 # Glitch Field, Inverse Field, Psychic Terrain
          return pbGetMoveScoreFunctionCode(getFunctionCode(:CONFUSERAY),callMove,realMove,
                 user,target,damage,effectChance)
        when 9,19 # Rainbow Field, Wasteland
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:HYPNOSIS),callMove,realMove,
                         user,target,damage,effectChance)
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:WILLOWISP),callMove,realMove,
                         user,target,damage,effectChance)
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:THUNDERWAVE),callMove,realMove,
                         user,target,damage,effectChance)
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:ICEBEAM),callMove,realMove,
                         user,target,damage,effectChance)
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:POISONGAS),callMove,realMove,
                         user,target,damage,effectChance)
          effectScore /= 5 # Average of all possibilities (don't input effectChance/5 because can mess with Serene Grace and etc.)
          echo("\n[AI - #{Time.now - $time}] Final effect score (0A4): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
      #---------------------------------------------------------------------------
      when "0A5" # Aerial Ace
      #---------------------------------------------------------------------------
      when "0A6" # Lock-On
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0A6): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0A7" # Foresight
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0A7): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0A8" # Miracle Eye
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0A8): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0A9" # Sacred Sword
      #---------------------------------------------------------------------------
      when "0AA" # Protect
        effectScore += pbGetMoveScoreFunctionCode("UserDamageProtection",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserNonDamageProtection",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0AA): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0AB" # Quick Guard
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0AB): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0AC" # Wide Guard
        effectScore = 0.0 #35
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0AC): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0AD" # Feint
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0AD): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0AE" # Mirror Move
        # Should not normally be called
        effectScore = 0.0 #20
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0AE): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0AF" # Copycat
        # Sometimes will not be called
        effectScore = 0.0 #20
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0AF): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0B0" # Me First
        effectScore = 0.0 #15
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0B0): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0B1" # Magic Coat
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0B1): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0B2" # Snatch
        effectScore = 0.0 #5
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0B2): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0B3" # Nature Power
        # Should not normally be called
      #---------------------------------------------------------------------------
      when "0B4" # Sleep Talk
        effectScore = 0.0 #30
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0B4): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0B5" # Assist
        effectScore = 0.0 #15
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0B5): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0B6" # Metronome
        effectScore = 0.0 #20
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0B6): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0B7" # Torment
        effectScore = 0.0 #(user.opposes?(target)) ? 10.0 : -10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0B7): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0B8" # Imprison
        effectScore = 0.0 #(user.opposes?(target)) ? 5.0 : -5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0B8): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0B9" # Disable
        effectScore = 0.0 #(user.opposes?(target)) ? 25.0 : -25.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0B9): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0BA" # Taunt
        effectScore = 0.0 #(user.opposes?(target)) ? 25.0 : -25.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0BA): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0BB" # Heal Block
        effectScore = 0.0 #(user.opposes?(target)) ? 5.0 : -5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0BB): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0BC" # Encore
        # Change to account for predicted lock move
        return pbGetMoveScoreFunctionCode("LockTargetMove",callMove,realMove,
               user,target,damage,effectChance,target.lastRegularMoveUsed)
      #---------------------------------------------------------------------------
      when "0BD" # Double Hit
      #---------------------------------------------------------------------------
      when "0BF" # Twineedle
        return pbGetMoveScoreFunctionCode(getFunctionCode(:POISONGAS),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "0C0" # Fury Attack
      #---------------------------------------------------------------------------
      when "0C1" # Beat Up
      #---------------------------------------------------------------------------
      when "0C2" # Hyper Beam
        effectScore = 0.0 #-30.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0C2): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0C3" # Razor Wind
        if callMove.pbIsChargingTurn?(user)
          effectScore += 1.0 * pbRoughDamage(callMove,realMove,user,target,false,false,true) / target.hp
          effectScore += pbGetMoveScoreFunctionCode("ChargeTurn",callMove,realMove,
                         user,target,damage,-2)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (0C3): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0C4" # Solar Beam
        if callMove.pbIsChargingTurn?(user)
          effectScore += 1.0 * pbRoughDamage(callMove,realMove,user,target,false,false,true) / target.hp
          effectScore += pbGetMoveScoreFunctionCode("ChargeTurn",callMove,realMove,
                         user,target,damage,-2)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (0C4): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0C5" # Freeze Shock
        if callMove.pbIsChargingTurn?(user)
          effectScore += 1.0 * pbRoughDamage(callMove,realMove,user,target,false,false,true) / target.hp
          effectScore += pbGetMoveScoreFunctionCode("ChargeTurn",callMove,realMove,
                         user,target,damage,-2)
        end
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:THUNDERWAVE),callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0C5): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0C6" # Ice Burn
        if callMove.pbIsChargingTurn?(user)
          effectScore += 1.0 * pbRoughDamage(callMove,realMove,user,target,false,false,true) / target.hp
          effectScore += pbGetMoveScoreFunctionCode("ChargeTurn",callMove,realMove,
                         user,target,damage,-2)
        end
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:WILLOWISP),callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0C6): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0C7" # Sky Attack
        if callMove.pbIsChargingTurn?(user)
          effectScore += 1.0 * pbRoughDamage(callMove,realMove,user,target,false,false,true) / target.hp
          effectScore += pbGetMoveScoreFunctionCode("ChargeTurn",callMove,realMove,
                         user,target,damage,-2)
        end
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:IRONHEAD),callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0C7): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0C8" # Skull Bash
        if callMove.pbIsChargingTurn?(user)
          effectScore += 1.0 * pbRoughDamage(callMove,realMove,user,target,false,false,true) / target.hp
          effectScore += pbGetMoveScoreFunctionCode("ChargeTurn",callMove,realMove,
                         user,target,damage,-2)
        end
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0C8): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0C9" # Fly
        if callMove.pbIsChargingTurn?(user)
          effectScore += 1.0 * pbRoughDamage(callMove,realMove,user,target,false,false,true) / target.hp
          effectScore += pbGetMoveScoreFunctionCode("ChargeTurn",callMove,realMove,
                         user,target,damage,-2)
        end
        effectScore += pbGetMoveScoreFunctionCode("SemiInvulnerable",callMove,realMove,
                       user,target,damage,-2)
        # Account for revealed moves that bypass semi-invulnerability
        echo("\n[AI - #{Time.now - $time}] Final effect score (0C9): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0CA" # Dig
        if callMove.pbIsChargingTurn?(user)
          effectScore += 1.0 * pbRoughDamage(callMove,realMove,user,target,false,false,true) / target.hp
          effectScore += pbGetMoveScoreFunctionCode("ChargeTurn",callMove,realMove,
                         user,target,damage,-2)
        end
        effectScore += pbGetMoveScoreFunctionCode("SemiInvulnerable",callMove,realMove,
                       user,target,damage,-2)
        # Account for revealed moves that bypass semi-invulnerability
        echo("\n[AI - #{Time.now - $time}] Final effect score (0CA): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0CB" # Dive
        if callMove.pbIsChargingTurn?(user)
          effectScore += 1.0 * pbRoughDamage(callMove,realMove,user,target,false,false,true) / target.hp
          effectScore += pbGetMoveScoreFunctionCode("ChargeTurn",callMove,realMove,
                         user,target,damage,-2)
        end
        effectScore += pbGetMoveScoreFunctionCode("SemiInvulnerable",callMove,realMove,
                       user,target,damage,-2)
        # Account for revealed moves that bypass semi-invulnerability
        echo("\n[AI - #{Time.now - $time}] Final effect score (0CB): #{effectScore}.")
      #---------------------------------------------------------------------------
      when "0CC" # Bounce
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:FLY),callMove,realMove,
                       user,target,damage,-2)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:THUNDERWAVE),callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0CC): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0CD" # Shadow Force
        if callMove.pbIsChargingTurn?(user)
          effectScore += 1.0 * pbRoughDamage(callMove,realMove,user,target,false,false,true) / target.hp
          effectScore += pbGetMoveScoreFunctionCode("ChargeTurn",callMove,realMove,
                         user,target,damage,-2)
        end
        effectScore += pbGetMoveScoreFunctionCode("SemiInvulnerable",callMove,realMove,
                       user,target,damage,-2)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:FEINT),callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0CD): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0CE" # Sky Drop
        if callMove.pbIsChargingTurn?(user)
          effectScore += 1.0 * pbRoughDamage(callMove,realMove,user,target,false,false,true) / target.hp
          effectScore += pbGetMoveScoreFunctionCode("ChargeTurn",callMove,realMove,
                         user,target,damage,-2)
        end
        effectScore += pbGetMoveScoreFunctionCode("SemiInvulnerable",callMove,realMove,
                       user,target,damage,-2)
        # Need to account for a lot more
        echo("\n[AI - #{Time.now - $time}] Final effect score (0CE): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0CF" # Wrap
        # Alter EOR damage based on field effect (not always 1/16)
        effectScore += pbGetMoveScoreFunctionCode("TargetEORDamage",callMove,realMove,
                       user,target,damage,effectChance,target.totalhp/16)
        # Alter duration based on items and such
        effectScore += pbGetMoveScoreFunctionCode("TargetTrap",callMove,realMove,
                       user,target,damage,effectChance,5.5)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0CF): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0D0" # Whirlpool
        return pbGetMoveScoreFunctionCode(getFunctionCode(:WRAP),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "0D1" # Uproar
        effectScore += pbGetMoveScoreFunctionCode("LockUserMove",callMove,realMove,
                       user,target,damage,-2,callMove)
        user.eachOtherBattler do |b|
          effectScore += pbGetMoveScoreFunctionCode("TargetSleepCure",callMove,realMove,
                         user,b,damage,-2)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (0D1): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0D2" # Thrash
        effectScore = 0.0 #-10.0 # Confuse user
        # Assumes you will get locked if using it through Metronome or something (maybe untrue?)
        effectScore += pbGetMoveScoreFunctionCode("LockUserMove",callMove,realMove,
                       user,target,damage,effectChance,callMove)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0D2): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0D3" # Rollout
        effectScore = 0.0 #10.0 # Score for setting up next higher damage
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        # Assumes you will get locked if using it through Metronome or something (maybe untrue?)
        effectScore += pbGetMoveScoreFunctionCode("LockUserMove",callMove,realMove,
                       user,target,damage,effectChance,callMove)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0D3): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0D4" # Bide
        effectScore = 0.0 #20.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0D4): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
  =begin
        # Takes a weighted average of all the damages of the opponents' moves
        # First order all damages that can be dealt in descending order
        damages = []
        user.eachNearOpposing do |b|
          for m in b.knownMoves
            if m.pp > 0 && !getVariableFixedFunctions.include?(m.function)
              temp = pbRoughDamage(m,m,b,user)
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
  =end
      #---------------------------------------------------------------------------
      when "0D5" # Recover
        return pbGetMoveScoreFunctionCode("UserHeal",callMove,realMove,
               user,target,damage,effectChance,callMove.pbHealAmount(user))
      #---------------------------------------------------------------------------
      when "0D6" # Roost
        effectScore += pbGetMoveScoreFunctionCode("UserHeal",callMove,realMove,
                       user,target,damage,effectChance,callMove.pbHealAmount(user))
        # Account for Flying-type removal
        echo("\n[AI - #{Time.now - $time}] Final effect score (0D6): #{effectScore}.")
      #---------------------------------------------------------------------------
      when "0D7" # Wish
        effectScore = 0.0 #30.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0D7): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0D8" # Synthesis
        return pbGetMoveScoreFunctionCode("UserHeal",callMove,realMove,
               user,target,damage,effectChance,callMove.pbHealAmount(user))
      #---------------------------------------------------------------------------
      when "0D9" # Rest
        effectScore += pbGetMoveScoreFunctionCode("UserHeal",callMove,realMove,
                       user,target,damage,effectChance,callMove.pbHealAmount(user))
        # Should better factor in self sleep score (make separate code rather than using Hypnosis)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:HYPNOSIS),callMove,realMove,
                       user,user,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0D9): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0DA" # Aqua Ring
        # Alter heal amount based on field effect
        return pbGetMoveScoreFunctionCode("UserEORHeal",callMove,realMove,
               user,target,damage,effectChance,user.totalhp/16)
      #---------------------------------------------------------------------------
      when "0DB" # Ingrain
        # Alter heal amount based on field effect
        effectScore += pbGetMoveScoreFunctionCode("UserEORHeal",callMove,realMove,
                       user,target,damage,effectChance,user.totalhp/16)
        effectScore += pbGetMoveScoreFunctionCode("UserTrap",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0DB): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0DC" # Leech Seed
        # Alter heal/damage amounts based on field effect
        effectScore += pbGetMoveScoreFunctionCode("UserEORHeal",callMove,realMove,
                       user,target,damage,effectChance,target.totalhp/8)
        effectScore += pbGetMoveScoreFunctionCode("TargetEORDamage",callMove,realMove,
                       user,target,damage,effectChance,target.totalhp/8)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0DC): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0DD" # Drain Punch
        # Account for Liquid Ooze
        return pbGetMoveScoreFunctionCode("UserHeal",callMove,realMove,
               user,target,damage,effectChance,damage/2)
      #---------------------------------------------------------------------------
      when "0DE" # Dream Eater
        return pbGetMoveScoreFunctionCode(getFunctionCode(:DRAINPUNCH),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "0DF" # Heal Pulse
        return pbGetMoveScoreFunctionCode("TargetHeal",callMove,realMove,
               user,target,damage,effectChance,callMove.pbHealAmount(user,target))
      #---------------------------------------------------------------------------
      when "0E0" # Explosion
        # Divide effect score by number of opponents because user is only knocked out once
        return pbGetMoveScoreFunctionCode("UserKO",callMove,realMove,
               user,target,damage,-2)
      #---------------------------------------------------------------------------
      when "0E1" # Final Gambit
        return pbGetMoveScoreFunctionCode("UserKO",callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "0E2" # Memento
        effectScore += pbGetMoveScoreFunctionCode("TargetAttackDown",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("TargetSpAtkDown",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("UserKO",callMove,realMove,
                       user,target,damage,-2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0E2): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0E3" # Healing Wish
        effectScore = 0.0 #15.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0E3): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0E4" # Lunar Dance
        effectScore = 0.0 #15.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0E4): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0E5" # Perish Song
        effectScore = 0.0 #20.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0E5): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0E6" # Grudge
        effectScore = 0.0 #5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0E6): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0E7" # Destiny Bond
        effectScore = 0.0 #25.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0E7): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0E8" # Endure
        effectScore = 0.0 #5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0E8): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0E9" # False Swipe
      #---------------------------------------------------------------------------
      when "0EA" # Teleport
        effectScore = 0.0 #15.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0EA): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0EB" # Whirlwind
        effectScore = 0.0 #user.opposes?(target) ? 20.0 : -20.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0EB): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0EC" # Circle Throw
        return pbGetMoveScoreFunctionCode(getFunctionCode(:WHIRLWIND),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "0ED" # Baton Pass
        effectScore = 0.0 #30.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0ED): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0EE" # Volt Switch
        return pbGetMoveScoreFunctionCode(getFunctionCode(:TELEPORT),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "0EF" # Mean Look, Anchor Shot
        return pbGetMoveScoreFunctionCode("TargetTrap",callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "0F0" # Knock Off
        return pbGetMoveScoreFunctionCode("TargetLoseItem",callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "0F1" # Thief
        effectScore += pbGetMoveScoreFunctionCode("TargetLoseItem",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserGainItem",callMove,realMove,
                       user,target,damage,effectChance,target.item_id)
        # Account for when the user has an item already or target has unlosable/ungainable item (no extra effect occurs)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0F1): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0F2" # Trick
        effectScore += pbGetMoveScoreFunctionCode("TargetLoseItem",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserLoseItem",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("TargetGainItem",callMove,realMove,
                       user,target,damage,effectChance,user.item_id)
        effectScore += pbGetMoveScoreFunctionCode("UserGainItem",callMove,realMove,
                       user,target,damage,effectChance,target.item_id)
        # Account for unswappable items (no extra effect occurs)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0F2): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0F3" # Bestow
        effectScore += pbGetMoveScoreFunctionCode("UserLoseItem",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("TargetGainItem",callMove,realMove,
                       user,target,damage,effectChance,user.item_id)
        # Account for when the target has an item already or user has unlosable/ungainable item (no extra effect occurs)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0F3): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0F4" # Bug Bite
        if target.item && GameData::Item.get(target.item).is_berry?
          effectScore += pbGetMoveScoreFunctionCode("TargetLoseItem",callMove,realMove,
                         user,target,damage,effectChance)
          effectScore += pbGetMoveScoreFunctionCode("UserGainItem",callMove,realMove,
                         user,target,damage,effectChance,target.item_id)
          # Account for when target has unlosable item (no extra effect occurs)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (0F4): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0F5" # Incinerate
        if target.item && GameData::Item.get(target.item).is_berry?
          effectScore += pbGetMoveScoreFunctionCode("TargetLoseItem",callMove,realMove,
                         user,target,damage,effectChance)
          # Account for when target has unlosable item (no extra effect occurs)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (0F5): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0F6" # Recycle
        # Check if recycleItem is an ID (should be)
        effectScore += pbGetMoveScoreFunctionCode("UserGainItem",callMove,realMove,
                       user,target,damage,effectChance,user.recycleItem)
        # Account for when user has item already
        echo("\n[AI - #{Time.now - $time}] Final effect score (0F6): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0F7" # Fling
        effectScore += pbGetMoveScoreFunctionCode("UserLoseItem",callMove,realMove,
                       user,target,damage,effectChance,user.item_id)
        case user.item_id
        when :POISONBARB
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:POISONGAS),callMove,realMove,
                         user,target,damage,effectChance)
        when :TOXICORB
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:TOXIC),callMove,realMove,
                         user,target,damage,effectChance)
        when :FLAMEORB, :COFFEE, :COFFEE1
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:WILLOWISP),callMove,realMove,
                         user,target,damage,effectChance)
        when :LIGHTBALL
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:THUNDERWAVE),callMove,realMove,
                         user,target,damage,effectChance)
        when :KINGSROCK, :RAZORFANG
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:IRONHEAD),callMove,realMove,
                         user,target,damage,effectChance)
        end # To-Do: else general item consumption effect (for berries and such)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0F7): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0F8" # Embargo
        effectScore = 0.0 #user.opposes?(target) ? 10.0 : -10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0F8): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0F9" # Magic Room
        effectScore = 0.0 #5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0F9): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0FA" # Wild Charge
        return pbGetMoveScoreFunctionCode("UserDamage",callMove,realMove,
               user,target,damage,effectChance,damage/4)
      #---------------------------------------------------------------------------
      when "0FB" # Brave Bird
        return pbGetMoveScoreFunctionCode("UserDamage",callMove,realMove,
               user,target,damage,effectChance,damage/3)
      #---------------------------------------------------------------------------
      when "0FC" # Head Smash
        return pbGetMoveScoreFunctionCode("UserDamage",callMove,realMove,
               user,target,damage,effectChance,damage/2)
      #---------------------------------------------------------------------------
      when "0FD" # Volt Tackle
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:THUNDERWAVE),callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserDamage",callMove,realMove,
                       user,target,damage,0,damage/3)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0FD): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0FE" # Flare Blitz
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:WILLOWISP),callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserDamage",callMove,realMove,
                       user,target,damage,0,damage/3)
        echo("\n[AI - #{Time.now - $time}] Final effect score (0FE): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "0FF" # Sunny Day
        # Modify input parameter to account for duration alterations
        return pbGetMoveScoreFunctionCode("SetSun",callMove,realMove,
               user,target,damage,effectChance,5)
      #---------------------------------------------------------------------------
      when "100" # Rain Dance
        # Modify input parameter to account for duration alterations
        return pbGetMoveScoreFunctionCode("SetRain",callMove,realMove,
               user,target,damage,effectChance,5)
      #---------------------------------------------------------------------------
      when "101" # Sandstorm
        # Modify input parameter to account for duration alterations
        return pbGetMoveScoreFunctionCode("SetSandstorm",callMove,realMove,
               user,target,damage,effectChance,5)
      #---------------------------------------------------------------------------
      when "102" # Hail
        # Modify input parameter to account for duration alterations
        return pbGetMoveScoreFunctionCode("SetHail",callMove,realMove,
               user,target,damage,effectChance,5)
      #---------------------------------------------------------------------------
      when "103" # Spikes
        effectScore = 0.0 #35.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (103): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "104" # Toxic Spikes
        effectScore = 0.0 #35.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (104): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "105" # Stealth Rock
        effectScore = 0.0 #35.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (105): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "106" # Grass Pledge
        effectScore = 0.0
        # No effect chance modifier because always occurs
        echo("\n[AI - #{Time.now - $time}] Final effect score (106): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "107" # Fire Pledge
        effectScore = 0.0
        # No effect chance modifier because always occurs
        echo("\n[AI - #{Time.now - $time}] Final effect score (107): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "108" # Water Pledge
        effectScore = 0.0
        # No effect chance modifier because always occurs
        echo("\n[AI - #{Time.now - $time}] Final effect score (108): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "109" # Pay Day
        effectScore = 0.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (109): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "10A" # Brick Break
        effectScore = 0.0 #10.0 # Breaks opponent's screens even when targeting ally
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (10A): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "10B" # Jump Kick
        return pbGetMoveScoreFunctionCode("UserDamage",callMove,realMove,
               user,target,damage,-1,user.totalhp/2)
      #---------------------------------------------------------------------------
      when "10C" # Substitute
        effectScore = 0.0 #25.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (10C): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "10D" # Curse
        if user.pbHasType?(:GHOST)
          effectScore = 0.0 #user.opposes?(target) ? 30.0 : -30.0
          effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        else
          effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("UserSpeedDown",callMove,realMove,
                         user,target,damage,effectChance,1)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (10D): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "10E" # Spite
        effectScore = 0.0 #user.opposes?(target) ? 5.0 : -5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (10E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "10F" # Nightmare
        effectScore = 0.0 #user.opposes?(target) ? 5.0 : -5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (10F): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "110" # Rapid Spin
        effectScore = 0.0 #10.0 # Score for hazard removal
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (110): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "111" # Future Sight
        effectScore = 1.0 * pbRoughDamage(callMove,realMove,user,target,false,false,true) / target.hp
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (111): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "112" # Stockpile
        effectScore = 0.0 #5.0 # Score for stockpile effect
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (112): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "113" # Spit Up
        effectScore = 0.0 #-5.0 # Score for removal of stockpile effect
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (113): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "114" # Swallow
        effectScore = 0.0 #-5.0 # Score for removal of stockpile effect
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserHeal",callMove,realMove,
                       user,target,damage,effectChance,callMove.pbHealAmount(user))
        echo("\n[AI - #{Time.now - $time}] Final effect score (114): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "115" # Focus Punch
      #---------------------------------------------------------------------------
      when "116" # Sucker Punch
        effectScore = 0.0 #-10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (116): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "117" # Follow Me
        effectScore = 0.0 #25.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (117): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "118" # Gravity
        effectScore = 0.0 #25.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (118): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "119" # Magnet Rise
        effectScore = 0.0 #5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (119): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "11A" # Telekinesis
        effectScore = 0.0 #user.opposes?(target) ? 5.0 : -5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (11A): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "11B" # Sky Uppercut
      #---------------------------------------------------------------------------
      when "11C" # Smack Down
        effectScore = 0.0 #user.opposes?(target) ? 5.0 : -5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (11C): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "11D" # After You
        effectScore = 0.0 #user.opposes?(target) ? -5.0 : 5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (11D): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "11E" # Quash
        effectScore = 0.0 #user.opposes?(target) ? 5.0 : -5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (11E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "11F" # Trick Room
        effectScore = 0.0 #30.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (11F): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "120" # Ally Switch
        effectScore = 0.0 #5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (120): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "121" # Foul Play
      #---------------------------------------------------------------------------
      when "122" # Psyshock
      #---------------------------------------------------------------------------
      when "123" # Synchronoise
      #---------------------------------------------------------------------------
      when "124" # Wonder Room
        effectScore = 0.0 #30.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (124): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "125" # Last Resort
      #---------------------------------------------------------------------------
      # 126 - 132 are shadow moves
      #---------------------------------------------------------------------------
      when "133" # Hold Hands
      #---------------------------------------------------------------------------
      when "134" # Celebrate
      #---------------------------------------------------------------------------
      when "135" # Freeze-Dry
        return pbGetMoveScoreFunctionCode(getFunctionCode(:ICEBEAM),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "136" # Diamond Storm
        # Divide effect score by number of targets because boost check only happens once
        return pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
               user,target,damage,effectChance,2)
      #---------------------------------------------------------------------------
      when "137" # Magnetic Flux
        user.eachOwnSideBattler do |b|
          next if !b.hasActiveAbility?([:PLUS,:MINUS])
          effectScore += pbGetMoveScoreFunctionCode("TargetDefenseUp",callMove,realMove,
                         user,b,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("TargetSpDefUp",callMove,realMove,
                         user,b,damage,effectChance,1)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (137): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "138" # Aromatic Mist
        return pbGetMoveScoreFunctionCode("TargetSpDefUp",callMove,realMove,
               user,target,damage,effectChance,1)
      #---------------------------------------------------------------------------
      when "139" # Play Nice
        return pbGetMoveScoreFunctionCode("TargetAttackDown",callMove,realMove,
               user,target,damage,effectChance,1)
      #---------------------------------------------------------------------------
      when "13A" # Noble Roar
        effectScore += pbGetMoveScoreFunctionCode("TargetAttackDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("TargetSpAtkDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (13A): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "13B" # Hyperspace Fury
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:FEINT),callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (13B): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "13C" # Confide
        return pbGetMoveScoreFunctionCode("TargetSpAtkDown",callMove,realMove,
               user,target,damage,effectChance,1)
      #---------------------------------------------------------------------------
      when "13D" # Eerie Impulse
        return pbGetMoveScoreFunctionCode("TargetSpAtkDown",callMove,realMove,
               user,target,damage,effectChance,2)
      #---------------------------------------------------------------------------
      when "13E" # Rototiller
        @battle.eachBattler do |b|
          next if !b.pbHasType?(:GRASS) || b.airborne? || b.semiInvulnerable?
          effectScore += pbGetMoveScoreFunctionCode("TargetAttackUp",callMove,realMove,
                         user,b,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("TargetSpAtkUp",callMove,realMove,
                         user,b,damage,effectChance,1)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (13E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "13F" # Flower Shield
        @battle.eachBattler do |b|
          next if !b.pbHasType?(:GRASS) || b.semiInvulnerable?
          effectScore += pbGetMoveScoreFunctionCode("TargetDefenseUp",callMove,realMove,
                         user,b,damage,effectChance,1)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (13F): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "140" # Venom Drench
        if target.poisoned?
          effectScore += pbGetMoveScoreFunctionCode("TargetAttackDown",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("TargetSpAtkDown",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("TargetSpeedDown",callMove,realMove,
                         user,target,damage,effectChance,1)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (140): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "141" # Topsy-Turvy
        GameData::Stat.each_battle { |s|
          level = target.stages[s.id]
          sign = (level > 0) ? "Down" : "Up"
          stat = nil
          case s.id
          when :ATTACK
            stat = "Attack"
          when :DEFENSE
            stat = "Defense"
          when :SPECIAL_ATTACK
            stat = "SpAtk"
          when :SPECIAL_DEFENSE
            stat = "SpDef"
          when :SPEED
            stat = "Speed"
          when :ACCURACY
            stat = "Accuracy"
          when :EVASION
            stat = "Evasion"
          end
          effectScore += pbGetMoveScoreFunctionCode("Target"+stat+sign,callMove,realMove,
                         user,target,damage,effectChance,level*2)
        }
        echo("\n[AI - #{Time.now - $time}] Final effect score (141): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "142" # Trick-or-Treat
        effectScore = 0.0 #15.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (142): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "143" # Forest's Curse
        effectScore = 0.0 #15.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (143): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "144" # Flying Press
      #---------------------------------------------------------------------------
      when "145" # Electrify
        effectScore = 0.0 #20.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (145): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "146" # Ion Deluge, Plasma Fists
        effectScore = 0.0 #20.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (146): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "147" # Hyperspace Hole
        return pbGetMoveScoreFunctionCode(getFunctionCode(:FEINT),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "148" # Powder
        effectScore = 0.0 #user.opposes?(target) ? 10.0 : -10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (148): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "149" # Mat Block
        user.eachOwnSideBattler do |b|
          effectScore += pbGetMoveScoreFunctionCode("TargetDamageProtection",callMove,realMove,
                         user,b,damage,effectChance)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (149): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "14A" # Crafty Shield
        user.eachOwnSideBattler do |b|
          effectScore += pbGetMoveScoreFunctionCode("TargetNonDamageProtection",callMove,realMove,
                         user,b,damage,effectChance)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (14A): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "14B" # King's Shield
        effectScore = 0.0 #10.0 # Attack drop score
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserDamageProtection",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (14B): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "14C" # Spiky Shield
        effectScore = 0.0 #10.0 # Contact damage score
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserDamageProtection",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserNonDamageProtection",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (14C): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "14D" # Phantom Force
        return pbGetMoveScoreFunctionCode(getFunctionCode(:SHADOWFORCE),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "14E" # Geomancy
        if callMove.pbIsChargingTurn?(user)
          effectScore += pbGetMoveScoreFunctionCode("ChargeTurn",callMove,realMove,
                         user,target,damage,-2)
        end
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (14E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "14F" # Draining Kiss
        # Account for Liquid Ooze
        return pbGetMoveScoreFunctionCode("UserHeal",callMove,realMove,
               user,target,damage,effectChance,damage*3/4)
      #---------------------------------------------------------------------------
      when "150" # Fell Stinger
        if damage >= target.hp
          return pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                 user,target,damage,effectChance,3)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (150): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "151" # Parting Shot
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:TELEPORT),callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("TargetAttackDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("TargetSpAtkDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (151): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "152" # Fairy Lock
        effectScore = 0.0 #5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (152): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "153" # Sticky Web
        effectScore = 0.0 #60.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (153): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "154" # Electric Terrain
        effectScore = fieldTransformationScore(1,5,user,true)
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (154): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "155" # Grassy Terrain
        effectScore = fieldTransformationScore(2,5,user,true)
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (155): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "156" # Misty Terrain
        effectScore = fieldTransformationScore(3,5,user,true)
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (156): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "157" # Happy Hour
        effectScore = 0.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (157): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "158" # Belch
      #---------------------------------------------------------------------------
      when "159" # Toxic Thread
        effectScore += pbGetMoveScoreFunctionCode("TargetSpeedDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:POISONGAS),callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (159): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "15A" # Sparkling Aria
        return pbGetMoveScoreFunctionCode("TargetBurnCure",callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "15B" # Purify
        effectScore += pbGetMoveScoreFunctionCode("TargetStatusCure",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserHeal",callMove,realMove,
                       user,target,damage,effectChance,callMove.pbHealAmount(user))
        echo("\n[AI - #{Time.now - $time}] Final effect score (15B): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "15C" # Gear Up
        user.eachOwnSideBattler do |b|
          next if !b.hasActiveAbility?([:PLUS,:MINUS])
          effectScore += pbGetMoveScoreFunctionCode("TargetAttackUp",callMove,realMove,
                         user,b,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("TargetSpAtkUp",callMove,realMove,
                         user,b,damage,effectChance,1)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (15C): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "15D" # Spectral Thief
        effectScore = 0.0 #10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (15D): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "15E" # Laser Focus
        effectScore = 0.0 #5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (15E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "15F" # Clanging Scales
        # Divide effect score by number of targets because boost check only happens once
        return pbGetMoveScoreFunctionCode("UserDefenseDown",callMove,realMove,
               user,target,damage,effectChance,1)
      #---------------------------------------------------------------------------
      when "160" # Strength Sap
        # Account for Liquid Ooze
        stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
        stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
        atk      = target.attack
        atkStage = target.stages[:ATTACK]+6
        healAmt = (atk.to_f*stageMul[atkStage]/stageDiv[atkStage]).floor
        effectScore += pbGetMoveScoreFunctionCode("UserHeal",callMove,realMove,
                       user,target,damage,effectChance,healAmt)
        effectScore += pbGetMoveScoreFunctionCode("TargetAttackDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (160): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "161" # Speed Swap
        effectScore = 0.0 #user.opposes?(target) ? 5.0 : -5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (161): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "162" # Burn Up
        effectScore = 0.0 #-10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (162): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "163" # Sunsteel Strike
      #---------------------------------------------------------------------------
      when "164" # Photon Geyser
      #---------------------------------------------------------------------------
      when "165" # Core Enforcer
        return pbGetMoveScoreFunctionCode(getFunctionCode(:GASTROACID),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "166" # Stomping Tantrum
      #---------------------------------------------------------------------------
      when "167" # Aurora Veil
        effectScore = 0.0 #60.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (167): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "168" # Baneful Bunker
        effectScore = 0.0 #10.0 # Poison score
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserDamageProtection",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserNonDamageProtection",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (168): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "169" # Revelation Dance
      #---------------------------------------------------------------------------
      when "16A" # Spotlight
        effectScore = 0.0 #user.opposes?(target) ? -5.0 : 5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (16A): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "16B" # Instruct
        effectScore = 0.0 #user.opposes?(target) ? -5.0 : 5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (16B): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "16C" # Throat Chop
        effectScore = 0.0 #user.opposes?(target) ? 5.0 : -5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (16C): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "16D" # Shore Up
        return pbGetMoveScoreFunctionCode("UserHeal",callMove,realMove,
               user,target,damage,effectChance,callMove.pbHealAmount(user))
      #---------------------------------------------------------------------------
      when "16E" # Floral Healing
        return pbGetMoveScoreFunctionCode("TargetHeal",callMove,realMove,
               user,target,damage,effectChance,callMove.pbHealAmount(user,target))
      #---------------------------------------------------------------------------
      when "16F" # Pollen Puff
        if !target.opposes?(user)
          return pbGetMoveScoreFunctionCode("TargetHeal",callMove,realMove,
                 user,target,damage,effectChance,target.totalhp/2)
        end
      #---------------------------------------------------------------------------
      when "170" # Mind Blown
        # Divide effect score by number of targets because boost check only happens once
        return pbGetMoveScoreFunctionCode("UserDamage",callMove,realMove,
               user,target,damage,-2,user.totalhp/2)
      #---------------------------------------------------------------------------
      when "171" # Shell Trap
      #---------------------------------------------------------------------------
      when "172" # Beak Blast
        effectScore = 0.0 #10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (172): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "173" # Psychic Terrain
        effectScore = fieldTransformationScore(37,5,user,true)
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score(173): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "174" # First Impression
      #---------------------------------------------------------------------------
      when "175" # Double Iron Bash
        return pbGetMoveScoreFunctionCode(getFunctionCode(:IRONHEAD),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "176" # Aura Wheel
        # Perhaps add code for form change score
        return pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
               user,target,damage,effectChance,1)
      #---------------------------------------------------------------------------
      when "177" # Body Press
      #---------------------------------------------------------------------------
      when "178" # Fishious Rend
      #---------------------------------------------------------------------------
      when "179" # Clangorous Soul
        if user.hp > [user.totalhp/3,1].max
          effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("UserDamage",callMove,realMove,
                         user,target,damage,0,[user.totalhp/3,1].max)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (179): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "17A" # Court Change
        effectScore = 0.0 #5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (17A): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "17B" # Decorate
        effectScore += pbGetMoveScoreFunctionCode("TargetAttackUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        effectScore += pbGetMoveScoreFunctionCode("TargetSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,2)
        echo("\n[AI - #{Time.now - $time}] Final effect score (17B): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "17C" # Dragon Darts
      #---------------------------------------------------------------------------
      when "17D" # Jaw Lock
        effectScore += pbGetMoveScoreFunctionCode("TargetTrap",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserTrap",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (17D): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "17E" # Life Dew
        return pbGetMoveScoreFunctionCode("TargetHeal",callMove,realMove,
               user,target,damage,effectChance,callMove.pbHealAmount(user,target))
      #---------------------------------------------------------------------------
      when "17F" # No Retreat
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserTrap",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (17F): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "180" # Obstruct
        effectScore = 0.0 #10.0 # Defense drop score
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserDamageProtection",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (180): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "181" # Octolock
        effectScore = 0.0 #user.opposes?(target) ? 15.0 : -15.0 # Each round Defense/Sp. Def drop score
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("TargetTrap",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (181): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "182" # Snipe Shot
      #---------------------------------------------------------------------------
      when "183" # Stuff Cheeks
        if user.item && GameData::Item.get(user.item).is_berry?
          effectScore = 0.0 #10 # Berry consumption score
          effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
          effectScore += pbGetMoveScoreFunctionCode("UserLoseItem",callMove,realMove,
                         user,target,damage,effectChance)
          effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                         user,target,damage,effectChance,2)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (183): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "184" # Teatime
        effectScore = 0.0 #5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (184): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "185" # Grav Apple
        return pbGetMoveScoreFunctionCode("TargetDefenseDown",callMove,realMove,
               user,target,damage,effectChance,1)
      #---------------------------------------------------------------------------
      when "186" # Tar Shot
        effectScore = 0.0 #user.opposes?(target) ? 10.0 : -10.0 # Fire weakness score
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("TargetSpeedDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (186): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "187" # Shell Side Arm
        return pbGetMoveScoreFunctionCode(getFunctionCode(:POISONGAS),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "188" # Surging Strikes
      #---------------------------------------------------------------------------
      when "189" # Jungle Healing
        effectScore += pbGetMoveScoreFunctionCode("TargetHeal",callMove,realMove,
                       user,target,damage,effectChance,callMove.pbHealAmount(user,target))
        effectScore += pbGetMoveScoreFunctionCode("TargetStatusCure",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (189): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "18A" # Terrain Pulse
      #---------------------------------------------------------------------------
      when "18B" # Burning Jealousy
        effectScore = 0.0 #10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (18B): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "18C" # Grassy Glide
      #---------------------------------------------------------------------------
      when "18D" # Rising Voltage
      #---------------------------------------------------------------------------
      when "18E" # Coaching
        effectScore += pbGetMoveScoreFunctionCode("TargetAttackUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("TargetDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (18E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "18F" # Corrosive Gas
        return pbGetMoveScoreFunctionCode("TargetLoseItem",callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "190" # Expanding Force
      #---------------------------------------------------------------------------
      when "191" # Meteor Beam
        if callMove.pbIsChargingTurn?(user)
          effectScore += 1.0 * pbRoughDamage(callMove,realMove,user,target,false,false,true) / target.hp
          effectScore += pbGetMoveScoreFunctionCode("ChargeTurn",callMove,realMove,
                         user,target,damage,-2)
        end
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (191): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "192" # Poltergeist
      #---------------------------------------------------------------------------
      when "193" # Scale Shot
        # Don't worry about it thinking the stat changes will happen once for each hit (caps at one)
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (193): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "194" # Lash Out
      #---------------------------------------------------------------------------
      when "195" # Steel Roller
        # Doesn't keep up with expected field calculations
        effectScore = fieldTransformationScore($febackup)
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (195): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "196" # Misty Explosion
        # Divide effect score by number of opponents because user is only knocked out once
        return pbGetMoveScoreFunctionCode("UserKO",callMove,realMove,
               user,target,damage,-2)
      #---------------------------------------------------------------------------
      when "197" # Magic Powder
        effectScore = 0.0 #30
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (197): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "198" # Eerie Spell
        effectScore = 0.0 #user.opposes?(target) ? 5.0 : -5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (198): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "199" # Dynamax Cannon
      #---------------------------------------------------------------------------
      when "19A" # Reactive Poison
        effectScore = 0.0 #user.opposes?(target) ? 5.0 : -5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (19A): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "19B" # Dragon Fleet
      #---------------------------------------------------------------------------
      when "19C" # Overclock
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,3)
        if user.hasRaisedStatStages?
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:CONFUSERAY),callMove,realMove,
                         user,user,damage,effectChance,3)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (19C): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "19D" # Mist Guard
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserEvasionUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (19D): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "19E" # Eternal Flame
        effectScore = 0.0 #10.0 # Score for setting up next higher damage
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        # Assumes you will get locked if using it through Metronome or something (maybe untrue?)
        effectScore += pbGetMoveScoreFunctionCode("LockUserMove",callMove,realMove,
                       user,target,damage,effectChance,callMove)
        echo("\n[AI - #{Time.now - $time}] Final effect score (19E): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "19F" # Dust Storm
        return pbGetMoveScoreFunctionCode("TargetAccuracyDown",callMove,realMove,
               user,target,damage,effectChance,1)
      #---------------------------------------------------------------------------
      when "1A0" # Infinite Force
        effectScore = 0.0 #10.0 # Score for setting up next higher damage
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        # Assumes you will get locked if using it through Metronome or something (maybe untrue?)
        effectScore += pbGetMoveScoreFunctionCode("LockUserMove",callMove,realMove,
                       user,target,damage,effectChance,callMove)
        echo("\n[AI - #{Time.now - $time}] Final effect score (1A0): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "1A1" # Tsunami
      #---------------------------------------------------------------------------
      when "1A2" # Chain Lightning
      #---------------------------------------------------------------------------
      when "1A3" # Ferocious Bellow
        effectScore += pbGetMoveScoreFunctionCode("TargetSpDefDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:IRONHEAD),callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (1A3): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "1A4" # Crisis Vine
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:SLUDGEBOMB),callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:SLEEPPOWDER),callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:IRONHEAD),callMove,realMove,
                       user,target,damage,effectChance)
        effectScore /= 3 # Average of all possibilities (don't input effectChance/3 because can mess with Serene Grace and etc.)
        echo("\n[AI - #{Time.now - $time}] Final effect score (1A4): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "1A5" # Barb Barrage
        return pbGetMoveScoreFunctionCode(getFunctionCode(:POISONGAS),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "1A6" # Bitter Malice
        return pbGetMoveScoreFunctionCode(getFunctionCode(:ICEBEAM),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "1A7" # Ceaseless Edge
        effectScore = 0.0 #user.opposes?(target) ? 10.0 : -10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (1A7): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "1A8" # Chloroblast
        effectScore += pbGetMoveScoreFunctionCode("UserDamage",callMove,realMove,
                       user,target,damage,-2,user.totalhp/2)
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (1A8): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "1A9" # Dire Claw
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:SLUDGEBOMB),callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:SLEEPPOWDER),callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:THUNDERBOLT),callMove,realMove,
                       user,target,damage,effectChance)
        effectScore /= 3 # Average of all possibilities (don't input effectChance/3 because can mess with Serene Grace and etc.)
        echo("\n[AI - #{Time.now - $time}] Final effect score (1A9): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "1AA" # Infernal Parade
        return pbGetMoveScoreFunctionCode(getFunctionCode(:WILLOWISP),callMove,realMove,
               user,target,damage,effectChance)
      #---------------------------------------------------------------------------
      when "1AB" # Lunar Blessing
        effectScore += pbGetMoveScoreFunctionCode("UserHeal",callMove,realMove,
                       user,target,damage,effectChance,callMove.pbHealAmount(user))
        effectScore += pbGetMoveScoreFunctionCode("UserEvasionUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserStatusCure",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (1AB): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "1AC" # Mystical Power
        highestNum = user.attack
        highestName = "Attack"
        if user.defense > highestNum
          highestNum = user.defense
          highestName = "Defense"
        end
        if user.spatk > highestNum
          highestNum = user.spatk
          highestName = "SpAtk"
        end
        if user.spdef > highestNum
          highestNum = user.spdef
          highestName = "SpDef"
        end
        return pbGetMoveScoreFunctionCode("User"+highestName+"Up",callMove,realMove,
               user,target,damage,effectChance,1)
      #---------------------------------------------------------------------------
      when "1AD" # Power Shift
        effectScore = 0.0 #5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (1AD): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "1AE" # Shelter
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserEvasionUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (1AE): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "1AF" # Springtide Storm
        if user.form == 0
          effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                         user,target,damage,effectChance,1)
        else
          effectScore += pbGetMoveScoreFunctionCode("TargetDefenseDown",callMove,realMove,
                         user,target,damage,effectChance,1)
          effectScore += pbGetMoveScoreFunctionCode("TargetSpDefDown",callMove,realMove,
                         user,target,damage,effectChance,1)
        end
        echo("\n[AI - #{Time.now - $time}] Final effect score (1AF): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "1B0" # Take Heart
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpAtkUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserSpDefUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserStatusCure",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (1B0): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "1B1" # Triple Arrows
        effectScore += pbGetMoveScoreFunctionCode("UserCritUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("TargetDefenseDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("TargetSpDefDown",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (1B1): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "1B2" # Victory Dance
        effectScore = 0.0 #15.0 # Score for damage multiplier
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserAttackUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserDefenseUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        echo("\n[AI - #{Time.now - $time}] Final effect score (1B2): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "1B3" # Wave Crash
        effectScore += pbGetMoveScoreFunctionCode("UserSpeedUp",callMove,realMove,
                       user,target,damage,effectChance,1)
        effectScore += pbGetMoveScoreFunctionCode("UserDamage",callMove,realMove,
                       user,target,damage,0,damage/3)
        echo("\n[AI - #{Time.now - $time}] Final effect score (1B3): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "UserDamage" # Parameter as damage amount
        effectScore = 100 * extraParam / user.hp
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (UserDamage): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "UserKO"
        # Doesn't negate your turn if you use the move that knocks you out
        return pbGetMoveScoreFunctionCode("UserDamage",callMove,realMove,
               user,target,damage,effectChance,user.totalhp)
      #---------------------------------------------------------------------------
      when "UserHeal" # Parameter as heal amount
        return pbGetMoveScoreFunctionCode("TargetHeal",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserEORHeal" # Parameter as heal amount
        return pbGetMoveScoreFunctionCode("TargetEORHeal",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "TargetHeal" # Parameter as heal amount
        if target.canHeal?
          effectScore = 100.0 * [extraParam,target.totalhp-target.hp].max / target.totalhp
          effectScore *= -1 if user.opposes?(target)
          effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
          echo("\n[AI - #{Time.now - $time}] Final effect score (TargetHeal): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        else
          effectScore = 0.0
          echo("\n[AI - #{Time.now - $time}] Final effect score (TargetHeal) is 0 because #{target.pbThis(true)} can't be healed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
      #---------------------------------------------------------------------------
      when "TargetEORHeal" # Parameter as heal amount
        return pbGetMoveScoreFunctionCode("TargetHeal",callMove,realMove,
               user,user,damage,effectChance,extraParam*2) # Assumes 2 turns of healing
      #---------------------------------------------------------------------------
      when "TargetEORDamage" # Parameter as damage amount
        effectScore = 100.0 * [extraParam,target.totalhp-target.hp].max / user.totalhp
        effectScore *= -1 if !user.opposes?(target)
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetEORDamage): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "UserAttackUp" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetAttackUp",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserDefenseUp" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetDefenseUp",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserSpAtkUp" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetSpAtkUp",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserSpDefUp" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetSpDefUp",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserSpeedUp" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetSpeedUp",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserAccuracyUp" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetAccuracyUp",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserEvasionUp" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetEvasionUp",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserCritUp" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetCritUp",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "TargetAttackUp" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? -10.0 * extraParam : 10.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetAttackUp): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetDefenseUp" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? -10.0 * extraParam : 10.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetDefenseUp): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetSpAtkUp" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? -10.0 * extraParam : 10.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetSpAtkUp): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetSpDefUp" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? -10.0 * extraParam : 10.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetSpDefUp): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetSpeedUp" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? -10.0 * extraParam : 10.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetSpeedUp): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetAccuracyUp" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? -10.0 * extraParam : 10.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetAccuracyUp): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetEvasionUp" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? -10.0 * extraParam : 10.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetEvasionUp): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetCritUp" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? -15.0 * extraParam : 15.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetCritUp): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "UserAttackDown" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetAttackDown",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserDefenseDown" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetDefenseDown",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserSpAtkDown" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetSpAtkDown",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserSpDefDown" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetSpDefDown",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserSpeedDown" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetSpeedDown",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserAccuracyDown" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetAccuracyDown",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserEvasionDown" # Parameter as number of stages
        return pbGetMoveScoreFunctionCode("TargetEvasionDown",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "TargetAttackDown" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? 5.0 * extraParam : -5.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetAttackDown): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetDefenseDown" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? 5.0 * extraParam : -5.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetDefenseDown): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetSpAtkDown" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? 5.0 * extraParam : -5.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetSpAtkDown): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetSpDefDown" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? 5.0 * extraParam : -5.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetSpDefDown): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetSpeedDown" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? 5.0 * extraParam : -5.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetSpeedDown): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetAccuracyDown" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? 5.0 * extraParam : -5.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetAccuracyDown): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetEvasionDown" # Parameter as number of stages
        effectScore = 0.0 #user.opposes?(target) ? 5.0 * extraParam : -5.0 * extraParam
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetEvasionDown): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "UserStatusCure"
        return pbGetMoveScoreFunctionCode("TargetStatusCure",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserBurnCure"
        return pbGetMoveScoreFunctionCode("TargetBurnCure",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserParalysisCure"
        return pbGetMoveScoreFunctionCode("TargetParalysisCure",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserPoisonCure"
        return pbGetMoveScoreFunctionCode("TargetPoisonCure",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserSleepCure"
        return pbGetMoveScoreFunctionCode("TargetSleepCure",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "UserFreezeCure"
        return pbGetMoveScoreFunctionCode("TargetFreezeCure",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "TargetStatusCure"
        effectScore += pbGetMoveScoreFunctionCode("TargetBurnCure",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("TargetParalysisCure",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("TargetPoisonCure",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("TargetSleepCure",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("TargetFreezeCure",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetStatusCure): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetBurnCure"
        effectScore = 0.0 #user.opposes?(target) ? -5.0 : 5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetBurnCure): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetParalysisCure"
        effectScore = 0.0 #user.opposes?(target) ? -5.0 : 5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetParalysisCure): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetPoisonCure"
        effectScore = 0.0 #user.opposes?(target) ? -5.0 : 5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetPoisonCure): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetSleepCure"
        effectScore = 0.0 #user.opposes?(target) ? -5.0 : 5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetSleepCure): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetFreezeCure"
        effectScore = 0.0 #user.opposes?(target) ? -5.0 : 5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetFreezeCure): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetFlashFire"
        effectScore = 0.0 #user.opposes?(target) ? -10.0 : 10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetFlashFire): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetMarvelScale"
        effectScore = 0.0 #user.opposes?(target) ? -10.0 : 10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetMarvelScale): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetToxicBoost"
        effectScore = 0.0 #user.opposes?(target) ? -10.0 : 10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetToxicBoost): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetGuts"
        effectScore = 0.0 #user.opposes?(target) ? -10.0 : 10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetToxicBoost): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetQuickFeet"
        effectScore = 0.0 #user.opposes?(target) ? -10.0 : 10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetQuickFeet): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "RaiseFlowerGarden"
        effectScore = 0.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (RaiseFlowerGarden): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "ChargeTurn"
        effectScore = 0.0 #-15.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (ChargeTurn): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "SemiInvulnerable"
        # Account for moves that bypass semi-invulnerability
        effectScore += pbGetMoveScoreFunctionCode("UserDamageProtection",callMove,realMove,
                       user,target,damage,effectChance)
        effectScore += pbGetMoveScoreFunctionCode("UserNonDamageProtection",callMove,realMove,
                       user,target,damage,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (SemiInvulnerable): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "LockUserMove" # Parameter as locked move
        return pbGetMoveScoreFunctionCode("LockTargetMove",callMove,realMove,
               user,user,damage,effectChance,extraParam)
      #---------------------------------------------------------------------------
      when "LockTargetMove" # Parameter as locked move
        effectScore = 0.0 #user.opposes?(target) ? 15.0 : -15.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (LockTargetMove): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "UserTrap" # Assumes lasts indefinitely
        return pbGetMoveScoreFunctionCode("TargetTrap",callMove,realMove,
               user,user,damage,effectChance,nil)
      #---------------------------------------------------------------------------
      when "TargetTrap" # Parameter as number of turns (nil means it lasts until user leaves)
        effectScore = 0.0 #user.opposes?(target) ? 10.0 : -10.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetTrap): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "UserLoseItem"
        return pbGetMoveScoreFunctionCode("TargetLoseItem",callMove,realMove,
               user,user,damage,effectChance)
      #---------------------------------------------------------------------------
      when "TargetLoseItem"
        effectScore = 0.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetLoseItem): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "UserGainItem" # Parameter as item ID that will be gained
        return pbGetMoveScoreFunctionCode("TargetGainItem",callMove,realMove,
               user,user,damage,effectChance)
      #---------------------------------------------------------------------------
      when "TargetGainItem" # Parameter as item ID that will be gained
        effectScore = 0.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetGainItem): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "SetSun" # Parameter as duration (-1 if indefinite and 0 if as long as user is active)
        effectScore = 0.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (SetSun): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "SetRain" # Parameter as duration (-1 if indefinite and 0 if as long as user is active)
        effectScore = 0.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (SetRain): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "SetSandstorm" # Parameter as duration (-1 if indefinite and 0 if as long as user is active)
        effectScore = 0.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (SetSandstorm): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "SetHail" # Parameter as duration (-1 if indefinite and 0 if as long as user is active)
        effectScore = 0.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (SetHail): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "SetHarshSun" # Parameter as duration (-1 if indefinite and 0 if as long as user is active)
        effectScore = 0.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (SetHarshSun): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "SetHeavyRain" # Parameter as duration (-1 if indefinite and 0 if as long as user is active)
        effectScore = 0.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (SetHeavyRain): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "SetStrongWinds" # Parameter as duration (-1 if indefinite and 0 if as long as user is active)
        effectScore = 0.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (SetStrongWinds): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "UserDamageProtection"
        return pbGetMoveScoreFunctionCode("TargetDamageProtection",callMove,realMove,
               user,user,damage,effectChance)
      #---------------------------------------------------------------------------
      when "UserNonDamageProtection"
        return pbGetMoveScoreFunctionCode("TargetNonDamageProtection",callMove,realMove,
               user,user,damage,effectChance)
      #---------------------------------------------------------------------------
      when "TargetDamageProtection"
        effectScore = 0.0 #user.opposes?(target) ? -20.0 : 20.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetDamageProtection): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      when "TargetNonDamageProtection"
        effectScore = 0.0 #user.opposes?(target) ? -5.0 : 5.0
        effectScore = effectChanceModifier(callMove,realMove,user,target,effectScore,effectChance)
        echo("\n[AI - #{Time.now - $time}] Final effect score (TargetNonDamageProtection): #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      #---------------------------------------------------------------------------
      else
        echo("\n[AI - #{Time.now - $time}] Function does not exist: #{function}.")
      end
      return effectScore.round
    end
    
    def sleepCode(effectScore,callMove,realMove,user,target,damage,effectChance=callMove.addlEffect)
      if target.hasActiveAbility?(:MARVELSCALE)
        marvelMult = pbGetMoveScoreFunctionCode("TargetMarvelScale",callMove,realMove,
                     user,target,damage,0)
        effectScore += marvelMult
        echo("\n[AI - #{Time.now - $time}] Effect score +#{marvelMult} because #{target.pbThis(true)} has Marvel Scale. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if target.hasActiveAbility?(:DEEPSLEEP) && ![6,38,39,40].include?($fefieldeffect)
        healAmount = [2,42,48].include?($fefieldeffect) ? target.totalhp/4 : target.totalhp/8
        dsScore = pbGetMoveScoreFunctionCode("TargetEORHeal",callMove,realMove,user,target,damage,callMove.addlEffect,healAmount)
        if $fefieldeffect == 31
          dsScore += pbGetMoveScoreFunctionCode("TargetDamageProtection",callMove,realMove,user,target,damage,callMove.addlEffect,healAmount)
        end
        effectScore += dsScore
        echo("\n[AI - #{Time.now - $time}] Effect score +#{dsScore} because #{target.pbThis(true)} will recover HP as it sleeps. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      erScore = endOfRoundScore(user,target)
      effectScore += erScore
      echo("\n[AI - #{Time.now - $time}] Effect score +#{erScore} due to the end-of-round effects that will occur to #{target.pbThis(true)} while it can't move. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      if $fefieldeffect == 8 && target.affectedBySwamp?
        swampScore = pbGetMoveScoreFunctionCode("TargetSpeedDown",callMove,realMove,user,target,damage,callMove.addlEffect,1)
        effectScore += swampScore
        echo("\n[AI - #{Time.now - $time}] Effect score +#{swampScore} because #{target.pbThis(true)} will have its Speed lowered an extra stage at the end of the round. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      elsif $fefieldeffect == 9
        rainbowScore = pbGetMoveScoreFunctionCode("TargetEORHeal",callMove,realMove,user,target,damage,callMove.addlEffect,target.totalhp/16)
        effectScore += rainbowScore
        echo("\n[AI - #{Time.now - $time}] Effect score +#{rainbowScore} because #{target.pbThis(true)} will recover HP as it sleeps. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      elsif [40,42].include?($fefieldeffect)
        hauntedScore = pbGetMoveScoreFunctionCode("TargetEORDamage",callMove,realMove,user,target,damage,callMove.addlEffect,target.totalhp/16)
        effectScore += hauntedScore
        echo("\n[AI - #{Time.now - $time}] Effect score +#{hauntedScore} because #{target.pbThis(true)} will lose HP as it sleeps. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      elsif $fefieldeffect == 48
        beachScore = pbGetMoveScoreFunctionCode("TargetDefenseUp",callMove,realMove,user,target,damage,callMove.addlEffect,1)
        beachScore += pbGetMoveScoreFunctionCode("TargetSpDefUp",callMove,realMove,user,target,damage,callMove.addlEffect,1)
        effectScore += beachScore
        echo("\n[AI - #{Time.now - $time}] Effect score +#{beachScore} because #{target.pbThis(true)} will have its Defense and Sp. Def raised an extra stage at the end of the round. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if user.opposes?(target)
        user.eachOwnSideBattler do |b|
          # Doesn't take into account being immune to Dream Eater
          if b.hasKnownMoveFunction?(:DREAMEATER) && ![9,31,34,40,42].include?($fefieldeffect)
            if !b.healPrevention? && !target.hasActiveAbility?(:LIQUIDOOZE)
              effectScore *= 1.5
              echo("\n[AI - #{Time.now - $time}] Effect score x1.5 because #{b.pbThis(true)} has Dream Eater and can be healed by it. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            else
              effectScore *= 1.2
              echo("\n[AI - #{Time.now - $time}] Effect score x1.2 because #{b.pbThis(true)} has Dream Eater but can't be healed by it. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            end
          end
          if b.hasKnownMoveFunction?(:HEX) && $fefieldeffect != 40
            effectScore *= 1.3
            echo("\n[AI - #{Time.now - $time}] Effect score x1.3 because #{b.pbThis(true)} has Hex. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.takesIndirectDamage?
            if b.hasKnownMoveFunction?(:NIGHTMARE) && ![9,31,38,40,42].include?($fefieldeffect)
              effectScore *= 1.3
              echo("\n[AI - #{Time.now - $time}] Effect score x1.3 because #{b.pbThis(true)} has Nightmare and #{target.pbThis(true)} can be damaged by it. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            end
            if b.hasActiveAbility?(:BADDREAMS) && ![9,29,31,38,40].include?($fefieldeffect)
              effectScore *= 1.5
              echo("\n[AI - #{Time.now - $time}] Effect score x1.5 because #{b.pbThis(true)} has Bad Dreams and #{target.pbThis(true)} can be damaged by it. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            end
            if b.hasKnownMoveFunction?(:LEECHSEED) && target.effects[PBEffects::LeechSeed] == -1 &&
               !target.pbHasType?(:GRASS)
              effectScore *= 1.2
              echo("\n[AI - #{Time.now - $time}] Effect score x1.2 because #{b.pbThis(true)} can use Leech Seed on #{target.pbThis(true)}. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            end
          end
          setupMult = runSetupMoves(b,1.3)
          effectScore *= setupMult
          echo("\n[AI - #{Time.now - $time}] Effect score x#{setupMult} due to #{b.pbThis(true)}'s setup moves. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          if b.effects[PBEffects::Substitute] > 0 # Will still have Substitute up
            effectScore *= 1.4
            echo("\n[AI - #{Time.now - $time}] Effect score x1.4 because #{b.pbThis(true)} has a Substitute up. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          elsif b.hasKnownMoveFunction?(:SUBSTITUTE)
            effectScore *= 1.3
            echo("\n[AI - #{Time.now - $time}] Effect score x1.3 because #{b.pbThis(true)} has Substitute. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
        end
      end
      statMult = statChangeMult(target,1.2)
      effectScore *= statMult
      echo("\n[AI - #{Time.now - $time}] Effect score x#{statMult} due to #{target.pbThis(true)}'s stat changes. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      if target.hasKnownMoveFunction?([:SLEEPTALK,:SNORE])
        effectScore *= 0.2
        echo("\n[AI - #{Time.now - $time}] Effect score x0.2 because #{target.pbThis(true)} has revealed Sleep Talk or Snore. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if target.hasActiveAbility?(:NATURALCURE) && @battle.pbCanSwitch?(target.index)
        effectScore *= 0.3
        echo("\n[AI - #{Time.now - $time}] Effect score x0.3 because #{target.pbThis(true)} has Natural Cure and can switch out. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if target.effects[PBEffects::Confusion] > 0
        effectScore *= 0.7
        echo("\n[AI - #{Time.now - $time}] Effect score x0.7 because #{target.pbThis(true)} is confused. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if target.effects[PBEffects::Attract] >= 0
        effectScore *= 0.7
        echo("\n[AI - #{Time.now - $time}] Effect score x0.7 because #{target.pbThis(true)} is infatuated. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if target.hasActiveAbility?(:SHEDSKIN)
        effectScore *= 0.7
        echo("\n[AI - #{Time.now - $time}] Effect score x0.7 because #{target.pbThis(true)} has Shed Skin. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if target.hasActiveAbility?(:HYDRATION) && [:Rain,:HeavyRain].include?(@battle.pbWeather) ||
         target.hasActiveAbility?(:NATURALCURE) && ([2,15,31,42].include?($fefieldeffect) ||
         $fefieldeffect == 33 && $fecounter >= 2)
        effectScore *= 0.1
        echo("\n[AI - #{Time.now - $time}] Effect score x0.1 because #{target.pbThis(true)}'s sleep will be cured at the end of the round. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if $fefieldeffect == 24
        effectScore *= 1.3
        echo("\n[AI - #{Time.now - $time}] Effect score x1.3 because sleep can last for more turns than usual. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if target.hasActiveAbility?(:EARLYBIRD)
        effectScore *= 0.5
        echo("\n[AI - #{Time.now - $time}] Effect score x0.5 because #{target.pbThis(true)} has Early Bird. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if target.effects[PBEffects::Yawn] > 0 # Falls asleep at end of round
        yawnScore = pbGetMoveScoreFunctionCode(getFunctionCode(:HYPNOSIS),callMove,alwaysLastMove,
                    user,target,damage,effectChance)
        effectScore -= yawnScore
        echo("\n[AI - #{Time.now - $time}] Effect score -#{yawnScore} because #{target.pbThis(true)} is affected by Yawn. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      return effectScore
    end
    
    def poisonCode(effectScore,callMove,realMove,user,target,damage,effectChance=callMove.addlEffect)
      if target.pbCanPoison?(user,false,callMove) && (target.effects[PBEffects::Substitute] == 0 || 
         callMove.ignoresSubstitute?(user)) && checkEffect?(callMove,realMove,user,target,damage) &&
         !target.hasActiveItem?(:TOXICORB) && target.takesIndirectDamage?
        if target.hasActiveAbility?(:POISONHEAL)
          phScore = pbGetMoveScoreFunctionCode("TargetEORHeal",callMove,realMove,user,target,damage,callMove.addlEffect,target.totalhp/8)
          effectScore = phScore
          echo("\n[AI - #{Time.now - $time}] Effect score set to #{phScore} because #{target.pbThis(true)} will instead recover HP while poisoned. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        else
          if $fefieldeffect == 10
            effectScore *= 1.5
            echo("\n[AI - #{Time.now - $time}] Effect score x2 because #{target.pbThis(true)} will take more damage from being poisoned. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.hasActiveAbility?(:MARVELSCALE)
            marvelMult = pbGetMoveScoreFunctionCode("TargetMarvelScale",callMove,realMove,
                         user,target,damage,0)
            effectScore += marvelMult
            echo("\n[AI - #{Time.now - $time}] Effect score +#{marvelMult} because #{target.pbThis(true)} has Marvel Scale. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.hasActiveAbility?(:TOXICBOOST)
            toxicMult = pbGetMoveScoreFunctionCode("TargetToxicBoost",callMove,realMove,
                        user,target,damage,0)
            effectScore += toxicMult
            echo("\n[AI - #{Time.now - $time}] Effect score +#{toxicMult} because #{target.pbThis(true)} has Toxic Boost. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.hasActiveAbility?(:GUTS)
            gutsMult = pbGetMoveScoreFunctionCode("TargetGuts",callMove,realMove,
                       user,target,damage,0)
            effectScore += gutsMult
            echo("\n[AI - #{Time.now - $time}] Effect score +#{gutsMult} because #{target.pbThis(true)} has Guts. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.hasActiveAbility?(:QUICKFEET)
            quickMult = pbGetMoveScoreFunctionCode("TargetQuickFeet",callMove,realMove,
                        user,target,damage,0)
            effectScore += quickMult
            echo("\n[AI - #{Time.now - $time}] Effect score +#{quickMult} because #{target.pbThis(true)} has Quick Feet. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if user.opposes?(target)
            user.eachOwnSideBattler do |b|
              if b.hasActiveAbility?(:MERCILESS)
                effectScore *= 1.6
                echo("\n[AI - #{Time.now - $time}] Effect score x1.6 because #{b.pbThis(true)} has Merciless. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              end
              # Doesn't take into account being immune to these moves
              if ![10,11,19,26,41].include?($fefieldeffect)
                if b.hasKnownMoveFunction?(:VENOSHOCK)
                  effectScore *= 1.3
                  echo("\n[AI - #{Time.now - $time}] Effect score x1.3 because #{b.pbThis(true)} has Venoshock. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                end
                if b.hasKnownMoveFunction?(:VENOMDRENCH)
                  effectScore *= 1.6
                  echo("\n[AI - #{Time.now - $time}] Effect score x1.6 because #{b.pbThis(true)} has Venom Drench. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                end
                if b.hasKnownMoveFunction?(:REACTIVEPOISON)
                  effectScore *= 1.1
                  echo("\n[AI - #{Time.now - $time}] Effect score x1.1 because #{b.pbThis(true)} has Reactive Poison. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                end
              end
              if b.hasKnownMoveFunction?(:HEX) && $fefieldeffect != 40
                effectScore *= 1.3
                echo("\n[AI - #{Time.now - $time}] Effect score x1.3 because #{b.pbThis(true)} has Hex. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              end
              if b.effects[PBEffects::Substitute] > 0 # Will still have Substitute up
                effectScore *= 1.3
                echo("\n[AI - #{Time.now - $time}] Effect score x1.3 because #{b.pbThis(true)} has a Substitute up. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              elsif b.hasKnownMoveFunction?(:SUBSTITUTE)
                effectScore *= 1.2
                echo("\n[AI - #{Time.now - $time}] Effect score x1.2 because #{b.pbThis(true)} has Substitute. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              end
              if b.hasKnownMoveFunction?(:PROTECT) || b.hasKnownMoveFunction?(:SPIKYSHIELD) || 
                 b.hasKnownMoveFunction?(:KINGSSHIELD) || b.hasKnownMoveFunction?(:BANEFULBUNKER) || 
                 b.hasKnownMoveFunction?(:OBSTRUCT)
                effectScore *= 1.3
                echo("\n[AI - #{Time.now - $time}] Effect score x1.3 because #{b.pbThis(true)} has a protection move. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              end
            end
          end
          statMult = statChangeMult(target,1.2,true)
          effectScore *= statMult
          echo("\n[AI - #{Time.now - $time}] Effect score x#{statMult} due to #{target.pbThis(true)}'s defensive stat changes. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          if target.hasKnownMoveFunction?(:FACADE)
            effectScore *= 0.4
            echo("\n[AI - #{Time.now - $time}] Effect score x0.4 because #{target.pbThis(true)} has revealed Facade. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.hasKnownMoveFunction?(:REST)
            effectScore *= 0.4
            echo("\n[AI - #{Time.now - $time}] Effect score x0.4 because #{target.pbThis(true)} has revealed Rest. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          wallMult = target.wallRatio
          effectScore *= wallMult
          echo("\n[AI - #{Time.now - $time}] Effect score x#{wallMult} because #{target.pbThis(true)} has a walling ratio of #{wallMult}. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          if target.hasActiveAbility?(:NATURALCURE) && @battle.pbCanSwitch?(target.index)
            effectScore *= 0.3
            echo("\n[AI - #{Time.now - $time}] Effect score x0.3 because #{target.pbThis(true)} has Natural Cure and can switch out. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.effects[PBEffects::Confusion] > 0
            effectScore *= 1.1
            echo("\n[AI - #{Time.now - $time}] Effect score x1.1 because #{target.pbThis(true)} is confused. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.effects[PBEffects::Attract] >= 0
            effectScore *= 1.2
            echo("\n[AI - #{Time.now - $time}] Effect score x1.2 because #{target.pbThis(true)} is infatuated. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.hasActiveAbility?(:SHEDSKIN)
            effectScore *= 0.7
            echo("\n[AI - #{Time.now - $time}] Effect score x0.7 because #{target.pbThis(true)} has Shed Skin. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if target.hasActiveAbility?(:HYDRATION) && [:Rain,:HeavyRain].include?(@battle.pbWeather) ||
             target.hasActiveAbility?(:NATURALCURE) && ([2,15,31,42].include?($fefieldeffect) ||
             $fefieldeffect == 33 && $fecounter >= 2)
            effectScore *= 0.1
            echo("\n[AI - #{Time.now - $time}] Effect score x0.1 because #{target.pbThis(true)}'s sleep will be cured at the end of the round. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          if damage > 0
            if (target.hasActiveAbility?(:STURDY) || target.hasActiveItem?(:FOCUSSASH)) && 
               target.hp == target.totalhp
              effectScore *= 2
              echo("\n[AI - #{Time.now - $time}] Effect score x2 because #{target.pbThis(true)} has OHKO prevention and #{callMove.name} is damaging. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            end
          end
        end
        if $fefieldeffect == 19
          effectScore /= 5.0
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:HYPNOSIS),callMove,realMove,
                         user,target,damage,effectChance) / 5.0
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:THUNDERBOLT),callMove,realMove,
                         user,target,damage,effectChance) / 5.0
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:ICEBEAM),callMove,realMove,
                         user,target,damage,effectChance) / 5.0
          effectScore += pbGetMoveScoreFunctionCode(getFunctionCode(:FLAMETHROWER),callMove,realMove,
                         user,target,damage,effectChance) / 5.0
          echo("\n[AI - #{Time.now - $time}] Effect score set to #{effectScore} because #{callMove.name} will inflict a random status instead of poison.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
        if target.effects[PBEffects::Yawn] > 0 # Falls asleep at end of round
          yawnScore = pbGetMoveScoreFunctionCode(getFunctionCode(:HYPNOSIS),callMove,alwaysLastMove,
                      user,target,damage,effectChance)
          effectScore -= yawnScore
          echo("\n[AI - #{Time.now - $time}] Effect score -#{yawnScore} because #{target.pbThis(true)} is affected by Yawn. New effect score: #{effectScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
        return effectScore
      else
        echo("\n[AI - #{Time.now - $time}] Effect score x0 because #{target.pbThis(true)} won't be poisoned by #{callMove.name}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        return 0
      end
    end
    
    def fieldTransformationScore(field,duration=0,user=nil,preventReversion=false,overrideBackup=false)
      score = 0
      echo("\n[AI - #{Time.now - $time}] Final field transformation score (into #{field}): #{score}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      return 0
    end
  end
  