class PokeBattle_AI
    def pbChooseMoves
      # Choose move based on prior selection
      if @user.moveChoice.nil?
        # If there are no calculated choices, use Struggle (or an Encored move)
        @battle.pbAutoChooseMove(@user.index)
      else
        @battle.pbRegisterMove(@user.index,@user.moveChoice[:moveIndex],false)
        @battle.pbRegisterTarget(@user.index,@user.moveChoice[:targetIndex]) if @user.moveChoice[:targetIndex] >= 0
      end
    end
  
    def pbChooseEnemyZMove
      @battle.pbRegisterZMove(@user.index)
      @battle.pbRegisterMove(@user.index,@user.moveChoice[:moveIndex],false)
      @battle.pbRegisterTarget(@user.index,@user.moveChoice[:targetIndex])
        for i in @user.moves
        @user.effects[PBEffects::BaseMoves].push(i)
      end
    end
  
    #=============================================================================
    # Get scores for the given move against each possible target
    #=============================================================================
    # Give each move the same score for random selection with wild Pokemon
    def pbRegisterMoveWild(idxMove)
      move = @user.moves[idxMove]
      entry = { :moveIndex => idxMove, :score => 100, :targetIndex => -1,
                :callMove => move, :realMove => move, :targets => [],
                :damages => [] }
      @moveChoices.push(entry)
      echo("\n[AI - #{Time.now - $time}] #{@user.pbThis}'s #{move.name} is added as a choice with a score of 100 and a random target because it is wild.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
    end
    
    # Calculate scores for trainer moves to be compared later on
    def pbRegisterMoveTrainer(idxMove,zMove=false)
      if zMove # Upgrade base move to Z-Move
        # Not actually the real move, but use it anyway because Z-Moves use their own priority (not base move's)
        realMove = PokeBattle_ZMove.from_base_move(@battle,@user,@user.moves[idxMove],@user.item)
        echo("\n[AI - #{Time.now - $time}] #{@user.moves[idxMove].name} is being checked as if it's used as #{realMove.name}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      else
        realMove = @user.moves[idxMove]
      end
      callMove = changeMove(realMove,@user) # Field move change, Nature Power, etc.
      echo("\n[AI - #{Time.now - $time}] #{@user.pbThis}'s #{realMove.name} is actually going to be #{callMove.name}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      # Falsely assumes choice of target for some transformed moves
      realTargets = @user.pbFindTargets([0,0,0,-1],realMove,@user) # choices array just uses fourth value
      targets = @user.pbFindTargets([0,0,0,-1],callMove,@user) # choices array just uses fourth value
      target_data = callMove.pbTarget(@user)
      if targets.length > 0
        # If move affects one or more battlers
        if targets.length > 1
          # If move affects multiple battlers and you don't choose a particular one
          totalScore = 0
          targetArray = []
          fullDmgValues = []
        end
        @battle.eachBattler do |b|
          # Skip check works under assumption that multi-target moves can't become single-target
          if !(targets.length == 1 && @battle.pbMoveCanTarget?(@user.index,b.index,target_data)) &&
             !targets.include?(b)
            echo("\n\n[AI - #{Time.now - $time}] Skipping check for #{@user.pbThis(true)}'s #{callMove.name} against #{b.pbThis(true)} because it isn't targeted.\n") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            next
          elsif targets.length == 1
            redirect = redirectionCheck(@user,callMove)
            if !redirect.empty?
              if !redirect.include?(b)
                echo("\n\n[AI - #{Time.now - $time}] Skipping check for #{@user.pbThis(true)}'s #{callMove.name} against #{b.pbThis(true)} because the attack will be redirected away from it.\n") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                next
              end
            elsif !@user.opposes?(b) && @battle.pbSideSize(@user.index) > 1 && !AIPreferences::PARTNER_FUNCTIONS.include?(callMove.function)
              echo("\n\n[AI - #{Time.now - $time}] Skipping check for #{@user.pbThis(true)}'s #{callMove.name} against #{b.pbThis(true)} because it's a partner and the move will probably be harmful to it.\n") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              next
            end
          end
          echo("\n========== #{callMove.name} --> #{b.pbThis} ==========") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          # Set b's expected HP based on finalized prior hits (don't worry about other effects of hits)
          priorDamage = 0
          @user.eachAlly do |a|
            if !a.moveChoice.nil? # Ally has finalized an action
              for i in 0...a.moveChoice[:targets].length
                if a.moveChoice[:targets][i].index == b.index
                  priorDamage += a.moveChoice[:damages][i]
                  break
                end
              end
            end
          end
          oldBHP = b.hp
          b.hp -= priorDamage # Doesn't visually do anything, only for calculations
          echo("\n[AI - #{Time.now - $time}] #{@user.pbThis}'s allies are going to reduce #{b.pbThis(true)}'s HP from #{oldBHP} to #{b.hp} before this attack.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          dmgValue = pbRoughDamage(callMove,realMove,@user,b,false,$game_switches[AIPreferences::AI_LOG_SWITCH])
          echo("\n[AI - #{Time.now - $time}] Damage for #{@user.pbThis(true)}'s #{callMove.name} against #{b.pbThis(true)} is #{dmgValue}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          scoreValue = pbGetMoveScore(callMove,realMove,@user,b,dmgValue)
          echo("\n[AI - #{Time.now - $time}] Score for #{@user.pbThis(true)}'s #{callMove.name} against #{b.pbThis(true)} is #{scoreValue}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          # Adds score for target
          if targets.length > 1
            totalScore += scoreValue.round # Negation happens in pbGetMoveScore
            echo("\n[AI - #{Time.now - $time}] #{@user.pbThis}'s score for #{callMove.name} increases by #{scoreValue.round} due to its hit against #{b.pbThis(true)}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            targetArray.push(b)
            fullDmgValues.push(dmgValue)
          else
            # If move affects one battler of choice
            if realTargets.length != 1 # Copycat, Imprison -> Thunder Cage, Rock Slide -> Avalanche, etc.
              entry = { :moveIndex => idxMove, :score => scoreValue, :targetIndex => -1,
                        :callMove => callMove, :realMove => realMove, :targets => [],
                        :damages => [] } # No targets because we don't know them
              echo("\n[AI - #{Time.now - $time}] #{@user.pbThis}'s score for #{callMove.name} against #{b.pbThis(true)} is #{scoreValue} and it was added as a choice (even though target is random).") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            else
              entry = { :moveIndex => idxMove, :score => scoreValue, :targetIndex => b.index,
                        :callMove => callMove, :realMove => realMove, :targets => [b],
                        :damages => [dmgValue] }
              echo("\n[AI - #{Time.now - $time}] #{@user.pbThis}'s score for #{callMove.name} against #{b.pbThis(true)} is #{scoreValue} and it was added as a choice.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            end
            @moveChoices.push(entry)
          end
          b.hp = oldBHP # Resets HP to actual value
        end
        if targets.length > 1
          entry = { :moveIndex => idxMove, :score => totalScore, :targetIndex => -1,
                    :callMove => callMove, :realMove => realMove, :targets => targetArray,
                    :damages => fullDmgValues }
          @moveChoices.push(entry)
          echo("\n\n[AI - #{Time.now - $time}] #{@user.pbThis}'s #{callMove.name} has a total score of #{totalScore} and it was added as a choice.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
      else
        # If move has no targets, affects the user, a side, or the whole field
        # Not just non-damaging (Counter, Mirror Coat, Metal Burst)
        echo("\n========== #{callMove.name} (targets self/nobody) ==========") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        score = pbGetMoveScore(callMove,realMove,@user,nil,0)
        entry = { :moveIndex => idxMove, :score => score, :targetIndex => -1,
                  :callMove => callMove, :realMove => realMove, :targets => [],
                  :damages => [] }
        @moveChoices.push(entry)
        echo("\n[AI - #{Time.now - $time}] #{@user.pbThis}'s #{callMove.name} has a score of #{score} and it was added as a choice.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
    end
  
    #=============================================================================
    # Get a score for the given move being used against the given target
    #=============================================================================
    # Returns the score value for the given move's usage by the given user against the given target
    def pbGetMoveScore(callMove,realMove,user,target,damage=nil)
      echo("\n") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      # Damaging Move Fail Check
      case callMove.function
      when getFunctionCode(:SNORE)
        if !user.asleep?
          echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{user.pbThis(true)} is not asleep.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          score = 0
        end
      when getFunctionCode(:FAKEOUT),getFunctionCode(:FIRSTIMPRESSION)
        if user.turnCount > 1
          echo("\n[AI - #{Time.now - $time}] Score x0 b/c it's not #{user.pbThis(true)} first turn in battle.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          score = 0
        end
      when getFunctionCode(:NATURALGIFT)
        item = user.item
        if !item || !item.is_berry? || !user.itemActive?
          echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{user.pbThis(true)} is not holding a working berry.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          score = 0
        end
      when getFunctionCode(:EXPLOSION)
        if !moldBreaker?(callMove,user) && @battle.dampBattler?
          echo("\n[AI - #{Time.now - $time}] Score x0 b/c Damp (or a damp field effect) is activated.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          score = 0
        end
      when getFunctionCode(:FLING)
        fails = false
        if !user.item || !user.itemActive? || user.unlosableItem?(user.item) || user.item.is_berry? &&
           !user.canConsumeBerry? || user.item.is_TR? && Settings::MECHANICS_GENERATION >= 8
          fails = true
        end
        flingableItem = false
        callMove.flingPowers.each do |_power, items|
          next if !items.include?(user.item_id)
          flingableItem = true
          break
        end
        if fails || !flingableItem
          echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{user.pbThis(true)} does not have an item or has one that cannot be flung.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          score = 0
        end
      when getFunctionCode(:SPITUP)
        if user.effects[PBEffects::Stockpile]==0
          echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{user.pbThis(true)} has not stockpiled at all.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          score = 0
        end
      when getFunctionCode(:FOCUSPUNCH)
        if ![20,48].include?($fefieldeffect)
          numStatus = 0
          numIncapacitated = 0
          numDamageOnly = 0
          user.eachNearOpposing do |b|
            if [:SLEEP,:FROZEN].include?(b.status)
              numIncapacitated += 1
            elsif b.hasKnownStatusMove?
              numStatus += 1
            elsif b.hasKnownDamageMove?
              numDamageOnly += 1
            end
          end
          chance = 0.0 # Chance user will get damaged
          sideSize = @battle.pbSideSize(user.index)
          for i in 0...@battle.pbSideSize(user.index+1)
            if numIncapacitated > 0
              # User can't get damaged, so chance stays low
              numIncapacitated -= 1
            elsif numStatus > 0
              chance += 0.4 / sideSize # 40% chance it will use the status move
              numStatus -= 1
            elsif numDamageOnly > 0
              chance += 1.0 / sideSize # 100% chance it will use a damaging move
              numDamageOnly -= 1
            else # No moves revealed
              chance += 0.8 / sideSize # 80% chance it will use a damaging move
            end
          end
          if rand < chance || [1,18].include?($fefieldeffect)
            echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{user.pbThis(true)} will probably be damaged before using its move, causing #{callMove.name} to fail.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            score = 0
          end
        end
      when getFunctionCode(:HYPERSPACEFURY)
        if user.form!=1
          echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{user.pbThis(true)} is not in the correct form to use the move.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          score = 0
        end
      when getFunctionCode(:BELCH)
        if !user.belched?
          echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{user.pbThis(true)} hasn't eaten a berry yet.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          score = 0
        end
      when getFunctionCode(:BURNUP)
        if !user.pbHasType?(:FIRE)
          echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{user.pbThis(true)} doesn't have the Fire-type.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          score = 0
        end
      when getFunctionCode(:MINDBLOWN)
        if !moldBreaker?(callMove,user) && @battle.dampBattler? && callMove.id == :MINDBLOWN
          echo("\n[AI - #{Time.now - $time}] Score x0 b/c Damp (or a damp field effect) is activated.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          score = 0
        end
      when getFunctionCode(:SHELLTRAP)
        numStatus = 0
        numIncapacitated = 0
        numPhysical = 0
        user.eachNearOpposing do |b|
          if [:SLEEP,:FROZEN].include?(b.status)
            numIncapacitated += 1
          elsif b.physicalAttackerRatio(user) > 0.5
            numPhysical += 1
            if b.hasKnownStatusMove?
              numStatus += 1
            end
          end
        end
        chance = 1.0 # Chance user won't be hit with a physical move (chance move will fail)
        sideSize = @battle.pbSideSize(user.index)
        oppSize = @battle.pbSideSize(user.index+1)
        for i in 0...oppSize
          if numIncapacitated > 0
            # User can't get damaged, so chance stays high
            numIncapacitated -= 1
          elsif numPhysical > 0
            if numStatus > 0
              chance -= 0.5 / sideSize # 50% chance it will use the physical move
              numPhysical -= 1
            else
              chance -= 0.8 / sideSize # 80% chance it will use the physical move
              numPhysical -= 1
            end
          end # else probably won't use physical move
        end
        if rand < chance
          echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{user.pbThis(true)} will probably not be hit with a physical move, causing #{callMove.name} to fail.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          score = 0
        end
      when getFunctionCode(:STEELROLLER)
        if $fefieldeffect == $febackup && ![4,14,25,30,44].include?($fefieldeffect)
          echo("\n[AI - #{Time.now - $time}] Score x0 b/c this field effect cannot be destroyed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          score = 0
        end
      end
      # Field Move Fail Check
      if callMove.failsDueToField?(user) || target && callMove.failsDueToFieldTarget?(user,target)
        echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{callMove.name} fails due to the field effect.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        score = 0
      end
      callMove.calcTypes = callMove.pbCalcTypes(user)
      # Immunity Check
      if target && pbCheckMoveImmunity(callMove,user,target)
        echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{callMove.name} has no effect against #{target.pbThis(true)}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        score = 0
      end
      if score.nil? # If not nil, then it's 0 from some fail check
        if damage.nil?
          damage = pbRoughDamage(callMove,realMove,user,target,false,$game_switches[AIPreferences::AI_LOG_SWITCH])
        end
        if target.nil?
          echo("\n[AI - #{Time.now - $time}] Average damage for #{user.pbThis(true)}'s #{callMove.name} is 0.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        else
          echo("\n[AI - #{Time.now - $time}] Average damage for #{user.pbThis(true)}'s #{callMove.name} against #{target.pbThis(true)} is #{damage}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
        score = pbGetMoveScoreDamage(callMove,realMove,user,target,damage)
        if target.nil?
          echo("\n[AI - #{Time.now - $time}] The initial damage score for #{user.pbThis(true)}'s #{callMove.name} is #{score}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        else
          echo("\n[AI - #{Time.now - $time}] The initial damage score for #{user.pbThis(true)}'s #{callMove.name} against #{target.pbThis(true)} is #{score}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
        effectScore = pbGetMoveScoreFunctionCode(callMove.function,callMove,realMove,user,target,damage)
        score += effectScore
        if target.nil?
          echo("\n[AI - #{Time.now - $time}] The initial effect score for #{user.pbThis(true)}'s #{callMove.name} is #{effectScore}, resulting in a combined score of #{score}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        else
          echo("\n[AI - #{Time.now - $time}] The initial effect score for #{user.pbThis(true)}'s #{callMove.name} against #{target.pbThis(true)} is #{effectScore}, resulting in a combined score of #{score}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
        if score > 0
          pri = pbMovePriority(realMove,user)
          moldBreaker = moldBreaker?(callMove,user)
          priorMoves = nil#expectedHitsBeforeAction(user,realMove)
          # Priority Moves
          if pri > 0
            if target
              if user.hasActiveAbility?(:PRANKSTER) && ![18,20,42].include?($fefieldeffect) &&
                 target.pbHasType?(:DARK) && target.opposes?(user) && callMove.statusMove?
                echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{callMove.name} is a status move, #{user.pbThis(true)} has #{user.abilityName}, and #{target.pbThis(true)} is Dark-type.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                score = 0
              elsif $fefieldeffect == 37 && target.opposes?(user)
                echo("\n[AI - #{Time.now - $time}] Score x0 b/c Psychic Terrain is active.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                score = 0
              elsif target.hasActiveAbility?([:DAZZLING,:QUEENLYMAJESTY]) && !moldBreaker
                echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} has #{target.abilityName}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                score = 0
              end
            end
            score *= 1.1 # Slightly prefer priority moves by default
            echo("\n[AI - #{Time.now - $time}] Score x1.1 b/c #{realMove.name} has an increased priority (#{pri}). New score: #{score}") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            user.eachNearOpposing do |b|
              if b.fasterThan?(user) && b.highestExpectedDamage(user) >= user.hp
                score *= 3
                echo("\n[AI - #{Time.now - $time}] Score x3 b/c #{realMove.name} will cause #{user.pbThis(true)} to move before #{b.pbThis(true)} will probably knock it out. New score: #{score}") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              end
            end
            if target && target.fasterThan?(user) && damage >= target.hp
              score *= 2
              echo("\n[AI - #{Time.now - $time}] Score x2 b/c #{realMove.name} will cause #{user.pbThis(true)} to move before #{b.pbThis(true)} who will be knocked out by this attack. New score: #{score}") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            end
          elsif pri < 0
            score *= 0.9 # Slightly discourage decreased priority moves by default
            echo("\n[AI - #{Time.now - $time}] Score x0.9 b/c #{realMove.name} has a decreased priority (#{pri}). New score: #{score}") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            user.eachNearOpposing do |b|
              if user.fasterThan?(b) && b.highestExpectedDamage(user) >= user.hp
                score *= 0.3
                echo("\n[AI - #{Time.now - $time}] Score x0.3 b/c #{realMove.name} will cause #{user.pbThis(true)} to move after #{b.pbThis(true)} will probably knock it out. New score: #{score}") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              end
            end
          end
          # Healing moves used by target - To do
          # Stance Change - To do
          # Dancer
          if callMove.danceMove?
            user.eachOtherBattler do |b|
              # Doesn't work well with partner score negation
              if (b.hasActiveAbility?(:DANCER) && $fefieldeffect != 12 && !([8,26].include?($fefieldeffect) &&
                 b.grounded?) || b.hasActiveAbility?([:QUICKFEET,:DEATHWALTZ,:PERFORMER]) && 
                 $fefieldeffect == 6) && !b.effects[PBEffects::Dancer]
                b.effects[PBEffects::Dancer] = true # Prevent infinite loop
                # Not quite accurate due to priority position not being after user
                otherUseScore = pbGetMoveScore(callMove,callMove,b,target)
                otherUseScore *= -1 if user.opposes?(b)
                score += otherUseScore
                echo("\n[AI - #{Time.now - $time}] Score +#{otherUseScore} b/c #{b.pbThis(true)}'s #{b.abilityName} will copy #{callMove.name}. New score: #{score}") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              end
              b.effects[PBEffects::Dancer] = false
            end
          end
  =begin
          # Destiny Bond
          if target && damage >= target.hp # Average damage, target must exist
            destinyMod = 0
            if target.effects[PBEffects::DestinyBond]
              destinyMod = pbGetMoveScoreFunctionCode("UserKO",callMove,realMove,user,target,damage,0)
              score += destinyMod
              echo("\n[AI - #{Time.now - $time}] Score +#{destinyMod} b/c #{target.pbThis(true)} is affected by Destiny Bond and #{callMove.name} is likely to kill. New score: #{score}") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            elsif (!target.effects[PBEffects::DestinyBondPrevious] || [31,40].include?($fefieldeffect)) && 
                  target.hasRevealedMoveFunction?(:DESTINYBOND) && target.movesBefore?(PokeBattle_Move.from_pokemon_move(@battle,Pokemon::Move.new(:DESTINYBOND)),user,realMove) &&
                  pbAIRandom(2) == 0 # Random unpredictability check
              destinyMod = 0.7*pbGetMoveScoreFunctionCode("UserKO",callMove,realMove,user,target,damage,0)
              score += destinyMod
              echo("\n[AI - #{Time.now - $time}] Score +#{destinyMod} b/c #{target.pbThis(true)} has revealed Destiny Bond, #{callMove.name} is likely to kill, and random check was passed. New score: #{score}") if $game_switches[AIPreferences::AI_LOG_SWITCH]
            end
          end
          # Ion Deluge - To do
          # Powder
          if callMove.calcTypes.include?(:FIRE)
            user.eachNearOpposing do |b|
              if b.hasRevealedMoveFunction?(:POWDER) && b.movesBefore?(PokeBattle_Move.from_pokemon_move(@battle,Pokemon::Move.new(:POWDER)),user,realMove) &&
                 pbAIRandom(2) == 0 # Random unpredictability check
                score = pbGetMoveScoreFunctionCode("UserDamage",callMove,realMove,user,user,0,0,user.totalhp/4)
                echo("\n[AI - #{Time.now - $time}] Score set to #{score} b/c #{b.pbThis(true)} has revealed Powder, #{callMove.name} is Fire-type, and random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              end
            end
          end
          # Snatch
          if realMove.canSnatch?
            if priorMoves.nil?
              priorMoves = expectedHitsBeforeAction(user,realMove)
            end
            for hit in priorMoves
              if hit.function == getFunctionCode(:SNATCH)
                echo("\n[AI - #{Time.now - $time}] Score x0 b/c someone will use Snatch before #{user.pbThis(true)} will use #{realMove.name}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                score = 0
              end
            end
            @user.eachOpposing do |b|
              if pbAIRandom(2) == 0 && b.hasRevealedMoveFunction?(:SNATCH)
                # Not quite accurate due to priority position not being when user would go
                otherUseScore = -1 * pbGetMoveScore(callMove,callMove,b,user,0)
                echo("\n[AI - #{Time.now - $time}] Score set to #{otherUseScore} b/c #{b.pbThis(true)} has revealed Snatch, #{realMove.name} is affected by it, and the random check was passed. New score: #{score}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                score = otherUseScore
              end
            end
          end
          # Crafty Shield
          if callMove.statusMove? && !target.nil?
            if @user.opposes?(target) # Don't know target side's moves
              target.eachOwnSideBattler do |b|
                if pbAIRandom(3) == 0 && b.hasRevealedMoveFunction?(:CRAFTSHIELD)
                  echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{b.pbThis(true)} has revealed Crafty Shield, #{callMove.name} is affected by it, and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                  score = 0
                  break
                end
              end
            else # Know target side's moves
              if priorMoves.nil?
                priorMoves = expectedHitsBeforeAction(user,realMove)
              end
              for hit in priorMoves
                if hit.function == getFunctionCode(:CRAFTSHIELD)
                  echo("\n[AI - #{Time.now - $time}] Score x0 b/c an ally will use Crafty Shield before #{user.pbThis(true)} will use #{callMove.name} on it.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                  score = 0
                  break
                end
              end
            end
          end
          protectEnded = [getFunctionCode(:FEINT),getFunctionCode(:HYPERSPACEHOLE),getFunctionCode(:HYPERSPACEFURY)].include?(callMove.function)
          if callMove.canProtectAgainst?(user) && !protectEnded && !target.nil?
            if callMove.pbTarget(user).num_targets > 1
              # Wide Guard
              if @user.opposes?(target) # Don't know target side's moves
                target.eachOwnSideBattler do |b|
                  if pbAIRandom(3) == 0 && b.hasRevealedMoveFunction?(:WIDEGUARD)
                    echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{b.pbThis(true)} has revealed Wide Guard, #{callMove.name} is affected by it, and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                    score = 0
                    break
                  end
                end
              else # Know target side's moves
                if priorMoves.nil?
                  priorMoves = expectedHitsBeforeAction(user,realMove)
                end
                for hit in priorMoves
                  if hit.function == getFunctionCode(:WIDEGUARD)
                    echo("\n[AI - #{Time.now - $time}] Score x0 b/c an ally will use Wide Guard before #{user.pbThis(true)} will use #{callMove.name} on it.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                    score = 0
                    break
                  end
                end
              end
              # Shackle
              shackler = nil
              target.eachOwnSideBattler do |b|
                if b.hasActiveAbility?(:SHACKLE) && b.pokemon.height > user.pokemon.height
                  shackler = b
                  break
                end
              end
              if shackler && callMove.pbDamagingMove?
                echo("\n[AI - #{Time.now - $time}] Score x0 b/c an ally will use Wide Guard before #{user.pbThis(true)} will use #{callMove.name} on it.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                score = 0
              end
            end
            # Quick Guard
            if pbMovePriority(realMove,user) >= 1
              if @user.opposes?(target) # Don't know target side's moves
                target.eachOwnSideBattler do |b|
                  if pbAIRandom(3) == 0 && b.hasRevealedMoveFunction?(:QUICKGUARD)
                    echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{b.pbThis(true)} has revealed Quick Guard, #{callMove.name} is affected by it, and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                    score = 0
                    break
                  end
                end
              else # Know target side's moves
                if priorMoves.nil?
                  priorMoves = expectedHitsBeforeAction(user,realMove)
                end
                for hit in priorMoves
                  if hit.function == getFunctionCode(:QUICKGUARD)
                    echo("\n[AI - #{Time.now - $time}] Score x0 b/c an ally will use Quick Guard before #{user.pbThis(true)} will use #{realMove.name} on it.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                    score = 0
                    break
                  end
                end
              end
            end
            # Mat Block
            if callMove.damagingMove? && user.turnCount <= 1
              if @user.opposes?(target) # Don't know target side's moves
                target.eachOwnSideBattler do |b|
                  next if !b.movesBefore?(PokeBattle_Move.from_pokemon_move(@battle,Pokemon::Move.new(:MATBLOCK)),user,realMove)
                  if pbAIRandom(3) == 0 && b.hasRevealedMoveFunction?(:MATBLOCK)
                    echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{b.pbThis(true)} has revealed Mat Block, #{callMove.name} is affected by it, and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                    score = 0
                    break
                  end
                end
              else # Know target side's moves
                if priorMoves.nil?
                  priorMoves = expectedHitsBeforeAction(user,realMove)
                end
                for hit in priorMoves
                  if hit.function == getFunctionCode(:MATBLOCK)
                    echo("\n[AI - #{Time.now - $time}] Score x0 b/c an ally will use Mat Block before #{user.pbThis(true)} will use #{callMove.name} on it.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                    score = 0
                    break
                  end
                end
              end
            end
            # Deep Sleep + Fairy Tale Field
            if target.hasActiveAbility?(:DEEPSLEEP) && $fefieldeffect == 31 && target.asleep?
              echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} has Deep Sleep on the Fairy Tale Field while sleeping and #{callMove.name} is blocked by it.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              score = 0
            end
            if @battle.pbRandom(target.effects[PBEffects::ProtectRate]) == 0
              # King's Shield
              if callMove.damagingMove? || $fefieldeffect == 31 || $fefieldeffect == 5 && 
                 $fecounter%6 == 1
                if target.effects[PBEffects::KingsShield]
                  if callMove.pbContactMove?(user)
                    if $fefieldeffect == 31
                      newScore = getMoveScoreFunctionCode("UserAttackDown",callMove,realMove,user,target,damage,0,2)
                      newScore += getMoveScoreFunctionCode("UserSpAtkDown",callMove,realMove,user,target,damage,0,2)
                    else
                      newScore = getMoveScoreFunctionCode("UserAttackDown",callMove,realMove,user,target,damage,0,1)
                    end
                    echo("\n[AI - #{Time.now - $time}] Score set to #{newScore} b/c #{target.pbThis(true)} is affected by King's Shield and #{callMove.name} is a contact move.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                    score = newScore
                  else
                    echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} is affected by King's Shield and #{callMove.name} is a damaging move (but not contact).") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                    score = 0
                  end
                else
                  if @user.opposes?(target) # Don't know target's moves
                    if target.hasRevealedMoveFunction?(:KINGSSHIELD) && pbAIRandom(3) == 0
                      if callMove.pbContactMove?(user)
                        if $fefieldeffect == 31
                          newScore = getMoveScoreFunctionCode("UserAttackDown",callMove,realMove,user,target,damage,0,2)
                          newScore += getMoveScoreFunctionCode("UserSpAtkDown",callMove,realMove,user,target,damage,0,2)
                        else
                          newScore = getMoveScoreFunctionCode("UserAttackDown",callMove,realMove,user,target,damage,0,1)
                        end
                        echo("\n[AI - #{Time.now - $time}] Score set to #{newScore} b/c #{target.pbThis(true)} has revealed King's Shield, #{callMove.name} is a contact move, and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                        score = newScore
                      else
                        echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} has revealed King's Shield, #{callMove.name} is a damaging move (but not contact), and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                        score = 0
                      end
                    end
                  else # Know target's moves
                    if !target.moveChoice.nil? && target.moveChoice[:callMove].function == getFunctionCode(:KINGSSHIELD)
                      if callMove.pbContactMove?(user)
                        if $fefieldeffect == 31
                          newScore = getMoveScoreFunctionCode("UserAttackDown",callMove,realMove,user,target,damage,0,2)
                          newScore += getMoveScoreFunctionCode("UserSpAtkDown",callMove,realMove,user,target,damage,0,2)
                        else
                          newScore = getMoveScoreFunctionCode("UserAttackDown",callMove,realMove,user,target,damage,0,1)
                        end
                        echo("\n[AI - #{Time.now - $time}] Score set to #{newScore} b/c #{target.pbThis(true)} is going to use King's Shield and #{callMove.name} is a contact move.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                        score = newScore
                      else
                        echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} is going to use King's Shield and #{callMove.name} is a damaging move (but not contact).") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                        score = 0
                      end
                    end
                  end
                end
              end
              if callMove.damagingMove? || [5,14,15].include?($fefieldeffect)
                # Obstruct
                if target.effects[PBEffects::Obstruct]
                  if callMove.pbContactMove?(user)
                    newScore = getMoveScoreFunctionCode("UserDefenseDown",callMove,realMove,user,target,damage,0,2)
                    echo("\n[AI - #{Time.now - $time}] Score set to #{newScore} b/c #{target.pbThis(true)} is affected by Obstruct and #{callMove.name} is a contact move.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                    score = newScore
                  else
                    echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} is going to use Obstruct and #{callMove.name} is a damaging move (but not contact).") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                    score = 0
                  end
                else
                  if @user.opposes?(target) # Don't know target's moves
                    if target.hasRevealedMoveFunction?(:OBSTRUCT) && pbAIRandom(3) == 0
                      if callMove.pbContactMove?(user)
                        newScore = getMoveScoreFunctionCode("UserDefenseDown",callMove,realMove,user,target,damage,0,2)
                        echo("\n[AI - #{Time.now - $time}] Score set to #{newScore} b/c #{target.pbThis(true)} has revealed Obstruct, #{callMove.name} is a contact move, and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                        score = newScore
                      else
                        echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} has revealed Obstruct, #{callMove.name} is a damaging move (but not contact), and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                        score = 0
                      end
                    end
                  else # Know target's moves
                    if !target.moveChoice.nil? && target.moveChoice[:callMove].function == getFunctionCode(:OBSTRUCT)
                      if callMove.pbContactMove?(user)
                        newScore = getMoveScoreFunctionCode("UserDefenseDown",callMove,realMove,user,target,damage,0,2)
                        echo("\n[AI - #{Time.now - $time}] Score set to #{newScore} b/c #{target.pbThis(true)} is going to use Obstruct and #{callMove.name} is a contact move.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                        score = newScore
                      else
                        echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} is going to use Obstruct and #{callMove.name} is a damaging move (but not contact).") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                        score = 0
                      end
                    end
                  end
                end
              end
              # Spiky Shield
              if target.effects[PBEffects::SpikyShield]
                if callMove.pbContactMove?(user)
                  if $fefieldeffect == 49
                    newScore = getMoveScoreFunctionCode("UserDamage",callMove,realMove,user,target,damage,0,user.totalhp/8)
                  else
                    newScore = getMoveScoreFunctionCode("UserDamage",callMove,realMove,user,target,damage,0,user.totalhp/4)
                  end
                  echo("\n[AI - #{Time.now - $time}] Score set to #{newScore} b/c #{target.pbThis(true)} is affected by Spiky Shield and #{callMove.name} is a contact move.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                  score = newScore
                else
                  echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} is affected by Spiky Shield and #{callMove.name} is blocked by it (but not contact).") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                  score = 0
                end
              else
                if @user.opposes?(target) # Don't know target's moves
                  if target.hasRevealedMoveFunction?(:SPIKYSHIELD) && @battle.pbRandom(user.effects[PBEffects::ProtectRate]) == 0 &&
                     pbAIRandom(3) == 0
                    if callMove.pbContactMove?(user)
                      if $fefieldeffect == 49
                        newScore = getMoveScoreFunctionCode("UserDamage",callMove,realMove,user,target,damage,0,user.totalhp/8)
                      else
                        newScore = getMoveScoreFunctionCode("UserDamage",callMove,realMove,user,target,damage,0,user.totalhp/4)
                      end
                      echo("\n[AI - #{Time.now - $time}] Score set to #{newScore} b/c #{target.pbThis(true)} has revealed Spiky Shield, #{callMove.name} is a contact move, and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                      score = newScore
                    else
                      echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} has revealed Spiky Shield, #{callMove.name} is blocked by it (but not contact), and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                      score = 0
                    end
                  end
                else # Know target's moves
                  if !target.moveChoice.nil? && target.moveChoice[:callMove].function == getFunctionCode(:SPIKYSHIELD)
                    if callMove.pbContactMove?(user)
                      if $fefieldeffect == 49
                        newScore = getMoveScoreFunctionCode("UserDamage",callMove,realMove,user,target,damage,0,user.totalhp/8)
                      else
                        newScore = getMoveScoreFunctionCode("UserDamage",callMove,realMove,user,target,damage,0,user.totalhp/4)
                      end
                      echo("\n[AI - #{Time.now - $time}] Score set to #{newScore} b/c #{target.pbThis(true)} is going to use Spiky Shield and #{callMove.name} is a contact move.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                      score = newScore
                    else
                      echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} is going to use Spiky Shield and #{callMove.name} is blocked by it (but not contact).") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                      score = 0
                    end
                  end
                end
              end
              # Baneful Bunker
              if target.effects[PBEffects::BanefulBunker]
                if callMove.pbContactMove?(user)
                  if [19,22].include?($fefieldeffect)
                    newScore = getMoveScoreFunctionCode(getFunctionCode(:TOXIC),callMove,realMove,user,user,damage,0)
                  else
                    newScore = getMoveScoreFunctionCode(getFunctionCode(:POISONGAS),callMove,realMove,user,user,damage,0)
                  end
                  echo("\n[AI - #{Time.now - $time}] Score set to #{newScore} b/c #{target.pbThis(true)} is affected by Baneful Bunker and #{callMove.name} is a contact move.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                  score = newScore
                else
                  echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} has revealed Baneful Bunker and #{callMove.name} is blocked by it (but not contact).") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                  score = 0
                end
              else
                if @user.opposes?(target) # Don't know target's moves
                  if target.hasRevealedMoveFunction?(:BANEFULBUNKER) && @battle.pbRandom(user.effects[PBEffects::ProtectRate]) == 0 &&
                     pbAIRandom(3) == 0
                    if callMove.pbContactMove?(user)
                      if [19,22].include?($fefieldeffect)
                        newScore = getMoveScoreFunctionCode(getFunctionCode(:TOXIC),callMove,realMove,user,user,damage,0)
                      else
                        newScore = getMoveScoreFunctionCode(getFunctionCode(:POISONGAS),callMove,realMove,user,user,damage,0)
                      end
                      echo("\n[AI - #{Time.now - $time}] Score set to #{newScore} b/c #{target.pbThis(true)} has revealed Baneful Bunker, #{callMove.name} is a contact move, and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                      score = newScore
                    else
                      echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} has revealed Baneful Bunker, #{callMove.name} is blocked by it (but not contact), and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                      score = 0
                    end
                  end
                else # Know target's moves
                  if !target.moveChoice.nil? && target.moveChoice[:callMove].function == getFunctionCode(:BANEFULBUNKER)
                    if callMove.pbContactMove?(user)
                      if [19,22].include?($fefieldeffect)
                        newScore = getMoveScoreFunctionCode(getFunctionCode(:TOXIC),callMove,realMove,user,user,damage,0)
                      else
                        newScore = getMoveScoreFunctionCode(getFunctionCode(:POISONGAS),callMove,realMove,user,user,damage,0)
                      end
                      echo("\n[AI - #{Time.now - $time}] Score set to #{newScore} b/c #{target.pbThis(true)} is going to use Baneful Bunker and #{callMove.name} is a contact move.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                      score = newScore
                    else
                      echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} is going to use Baneful Bunker and #{callMove.name} is blocked by it (but not contact).") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                      score = 0
                    end
                  end
                end
              end
              # Protect, Detect
              if target.effects[PBEffects::Protect]
                echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} is affected by Protect and #{callMove.name} is blocked by it.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                score = 0
              else
                if @user.opposes?(target) # Don't know target's moves
                  if target.hasRevealedMoveFunction?(:PROTECT) && pbAIRandom(3) == 0
                    echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} has revealed Protect, #{callMove.name} is blocked by it, and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                    score = 0
                  end
                else # Know target's moves
                  if !target.moveChoice.nil? && target.moveChoice[:callMove].function == getFunctionCode(:PROTECT)
                    echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{target.pbThis(true)} is going to use Protect and #{callMove.name} is blocked by it.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                    score = 0
                  end
                end
              end
            end
          end
          if !target.nil? && (callMove.canMagicCoat? || $fefieldeffect == 9 && callMove.numTargets(user) == 1 && 
             callMove.specialMove?) && !target.semiInvulnerable? && target.opposes?(user)
            # Magic Coat
            if target.effects[PBEffects::MagicCoat]
              otherUseScore = pbGetMoveScore(callMove,callMove,target,user)
              otherUseScore *= -1 if @user.opposes?(target)
              echo("\n[AI - #{Time.now - $time}] Score set to #{otherUseScore} b/c #{target.pbThis(true)} is affected by Magic Coat and #{callMove.name} is bounced by it.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              score = otherUseScore
            else
              if @user.opposes?(target) # Don't know target side's moves
                if pbAIRandom(3) == 0 && target.hasRevealedMoveFunction?(:MAGICCOAT)
                  otherUseScore = pbGetMoveScore(callMove,callMove,target,user)
                  otherUseScore *= -1 if @user.opposes?(target)
                  echo("\n[AI - #{Time.now - $time}] Score set to #{otherUseScore} b/c #{target.pbThis(true)} has revealed Magic Coat, #{callMove.name} is affected by it, and the random check was passed.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                  score = otherUseScore
                end
              else # Know target side's moves
                if priorMoves.nil?
                  priorMoves = expectedHitsBeforeAction(user,realMove)
                end
                for hit in priorMoves
                  if hit.function == getFunctionCode(:MAGICCOAT)
                    otherUseScore = pbGetMoveScore(callMove,callMove,target,user)
                    otherUseScore *= -1 if @user.opposes?(target)
                    echo("\n[AI - #{Time.now - $time}] Score set to #{otherUseScore} b/c #{target.pbThis(true)} is going to use Magic Coat before #{user.pbThis(true)} uses its move and #{callMove.name} is affected by it.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
                    score = otherUseScore
                    break
                  end
                end
              end
            end
            # Magic Bounce
            if target.hasActiveAbility?(:MAGICBOUNCE) && !@battle.moldBreaker
              otherUseScore = pbGetMoveScore(callMove,callMove,target,user)
              otherUseScore *= -1 if @user.opposes?(target)
              echo("\n[AI - #{Time.now - $time}] Score set to #{otherUseScore} b/c #{target.pbThis(true)} has Magic Bounce and #{callMove.name} is bounced by it.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
              score = otherUseScore
            end
          end
  =end
  =begin
          # Follow Me, Rage Powder, Ally Switch
          if PBTargets.oneTarget?(move.target) && (opposingRevealedMoveUser(user,[:FOLLOWME,:ALLYSWITCH]) || 
             opposingRevealedMoveUser(user,:RAGEPOWDER) && !user.avoidsPowderMoves)
            redirectOpp = opposingRevealedMoveUser(user,[:FOLLOWME,:ALLYSWITCH,:RAGEPOWDER],true)
            if opposingActiveCount(user) > 1 && redirectOpp != target # Multiple Opponents
              if pbAIRandom(3) == 0
                echo("\n[AI - #{Time.now - $time}] Score set to what it would be on #{redirectOpp.pbThis(true)} b/c it has Follow Me, Ally Switch, or Rage Powder, #{PBMoves.getName(move)} is single-target, and the random score change test was fulfilled.")
                echo("\n\n[AI - #{Time.now - $time}] Starting score rechoosing for #{redirectOpp.pbThis(true)}.")
                return pbGetMoveScore(move,user,redirectOpp,skill,dmgPercent,initialscores,scoreindex)
              end
            end
          end
          if move.damagingMove?
            if move.pbContactMove?(user)
              if !user.hasActiveAbility?(:MAGICGUARD)
                # Rough Skin, Iron Barbs, Rocky Helmet
                if target.hasActiveAbility?([:ROUGHSKIN,:IRONBARBS])
                  score*=(0.85*move.pbNumHits(user,target))
                  echo("\n[AI - #{Time.now - $time}] Score x#{(0.8*move.pbNumHits(user,target))} b/c #{target.pbThis(true)} has #{PBAbilities.getName(target.ability)} and #{PBMoves.getName(move)} is a contact move. New score: #{score}.")
                end
                if target.hasActiveItem?(:ROCKYHELMET)
                  score*=(0.85*move.pbNumHits(user,target))
                  echo("\n[AI - #{Time.now - $time}] Score x#{(0.85*move.pbNumHits(user,target))} b/c #{target.pbThis(true)} is holding a #{PBItems.getName(target.item)} and #{PBMoves.getName(move)} is a contact move. New score: #{score}.")
                end
                # Poison Touch
                if user.hasActiveAbility?(:POISONTOUCH) && target.pbCanPoison(user,false) && 
                   !knocksOut?(move,user,target,skill,move.baseDamage)
                  if target.hasRevealedMove(:PSYCHOSHIFT) && user.pbCanPoison?(target,false) ||
                     target.hasRevealedMove(:FACADE) || target.hasActiveAbility?([:GUTS,:QUICKFEET,:TOXICBOOST,:MARVELSCALE]) ||
                     target.hasActiveAbility?(:SYNCHRONIZE) && user.pbCanPoisonSynchronize(target) ||
                     partnerRevealedMove(target,:PURIFY,true)
                    score*=(0.5*move.pbNumHits(user,target))
                    echo("\n[AI - #{Time.now - $time}] Score x#{0.5*move.pbNumHits(user,target)} b/c #{target.pbThis(true)} benefits from poisoning by #{user.pbThis(true)}'s #{PBAbilities.getName(user.ability)}. New score: #{score}.")
                  elsif target.hasRevealedMove(:REST) || target.hasRevealedMove(:PSYCHOSHIFT) || 
                        opposingRevealedMoveUser(user,:AROMATHERAPY) || opposingRevealedMoveUser(user,:HEALBELL) ||
                        target.hasRevealedMove(:REFRESH) || mon.hasActiveAbility?([:NATURALCURE,:SHEDSKIN])
                    score*=(1.1*move.pbNumHits(user,target))
                    echo("\n[AI - #{Time.now - $time}] Score x#{1.1*move.pbNumHits(user,target)} b/c #{target.pbThis(true)} can get rid of poisoning by #{user.pbThis(true)}'s #{PBAbilities.getName(user.ability)}. New score: #{score}.")
                  elsif !(target.hasActiveAbility?(:HYDRATION) && (@battle.pbWeather==PBWeather::Rain || 
                        @battle.pbWeather==PBWeather::HeavyRain))
                    score*=(1.2*move.pbNumHits(user,target))
                    echo("\n[AI - #{Time.now - $time}] Score x#{1.2*move.pbNumHits(user,target)} to account for poison chance by #{user.pbThis(true)}'s #{PBAbilities.getName(user.ability)}. New score: #{score}.")
                  end   
                end
                # Aftermath
                if target.hasActiveAbility?(:AFTERMATH) && knocksOut?(move,user,target,skill,move.baseDamage)
                  score*=0.7
                  echo("\n[AI - #{Time.now - $time}] Score x0.7 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} knocks out #{target.pbThis(true)} and it has #{PBAbilities.getName(target.ability)} and it is a contact move. New score: #{score}.")
                end
                # Poison Point
                if target.hasActiveAbility?(:POISONPOINT) && user.pbCanPoison?(target,false)
                  if user.hasActiveAbility?([:GUTS,:MARVELSCALE,:TOXICBOOST,:QUICKFEET]) || 
                     user.hasRevealedMove(:FACADE)
                    score*=1.4
                    echo("\n[AI - #{Time.now - $time}] Score x1.4 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} can trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and it benefits from poison. New score: #{score}.")
                  else
                    score*=0.8 # Contact moves are usually for physical attackers
                    echo("\n[AI - #{Time.now - $time}] Score x0.8 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} can trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)}. New score: #{score}.")
                  end
                end
              end
              # Cute Charm
              if target.hasActiveAbility?(:CUTECHARM) && user.pbCanAttract?(target,false)
                score*=0.9
                echo("\n[AI - #{Time.now - $time}] Score x0.9 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} can trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)}. New score: #{score}.")
              end
              # Effect Spore
              if target.hasActiveAbility?(:EFFECTSPORE) && !user.avoidsPowderMoves && !@roles.include?("Status Absorber")
                score*=0.85
                echo("\n[AI - #{Time.now - $time}] Score x0.85 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} can trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)}. New score: #{score}.")
              end
              # Flame Body
              if target.hasActiveAbility?(:FLAMEBODY) && user.pbCanBurn?(target,false)
                if user.hasActiveAbility?([:GUTS,:MARVELSCALE,:FLAREBOOST,:QUICKFEET]) || 
                   user.hasRevealedMove(:FACADE)
                  score*=1.5
                  echo("\n[AI - #{Time.now - $time}] Score x1.5 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} can trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and it benefits from burns. New score: #{score}.")
                else
                  score*=0.7 # Contact moves are usually for physical attackers
                  echo("\n[AI - #{Time.now - $time}] Score x0.7 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} can trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)}. New score: #{score}.")
                end
              end
              # Static
              if target.hasActiveAbility?(:STATIC) && user.pbCanParalyze?(target,false)
                if user.hasActiveAbility?([:GUTS,:MARVELSCALE,:QUICKFEET]) || 
                   user.hasRevealedMove(:FACADE)
                  if !user.isFasterThan(target)
                    score*=1.5
                    echo("\n[AI - #{Time.now - $time}] Score x1.5 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} can trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and it benefits from paralysis. New score: #{score}.")
                  end
                else
                  if user.isFasterThan(target)
                    score*=0.7
                    echo("\n[AI - #{Time.now - $time}] Score x0.7 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} can trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and it is faster. New score: #{score}.")
                  else
                    score*=0.9
                    echo("\n[AI - #{Time.now - $time}] Score x0.9 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} can trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and it is slower. New score: #{score}.")
                  end
                end
              end
              # Gooey
              if target.hasActiveAbility?([:GOOEY,:TANGLINGHAIR]) && user.pbCanLowerStatStage?(PBStats::SPEED)
                if user.hasActiveAbility?(:CONTRARY)
                  if !user.isFasterThan(target)
                    score*=2 # Contact moves are usually for physical attackers
                    echo("\n[AI - #{Time.now - $time}] Score x2 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} will trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)}, it is slower, and it has #{PBAbilities.getName(user.ability)}. New score: #{score}.")
                  else
                    score*=1.3 # Contact moves are usually for physical attackers
                    echo("\n[AI - #{Time.now - $time}] Score x1.3 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} will trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)}, it is faster, and it has #{PBAbilities.getName(user.ability)}. New score: #{score}.")
                  end
                else
                  if user.isFasterThan(target)
                    score*=0.5 # Contact moves are usually for physical attackers
                    echo("\n[AI - #{Time.now - $time}] Score x0.5 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} will trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and it is faster. New score: #{score}.")
                  else
                    score*=0.8 # Contact moves are usually for physical attackers
                    echo("\n[AI - #{Time.now - $time}] Score x0.8 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} will trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and it is slower. New score: #{score}.")
                  end
                end
              end
            end
            # Anger Point
            if target.hasActiveAbility?(:ANGERPOINT) && !knocksOut?(move,user,target,skill,move.baseDamage,false,true) &&
               target.canRaiseStatStage?(PBStats::ATTACK)
              c = getCritRate(move,user,target)
              if c>0
                if target.opposes?(user) || c != 4
                  if target.physicalAttacker?
                    score*=0.2*(1.0/c)
                    echo("\n[AI - #{Time.now - $time}] Score x#{0.2*(1.0/c)} b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} has a high crit rate against #{target.pbThis(true)} who has #{PBAbilities.getName(target.ability)} and is a physical attacker. New score: #{score}.")
                  else
                    score*=1.0/c
                    echo("\n[AI - #{Time.now - $time}] Score x#{1.0/c} b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} has a high crit rate against #{target.pbThis(true)} who has #{PBAbilities.getName(target.ability)} and is not a physical attacker. New score: #{score}.")
                  end
                else # Guaranteed crit against a partner
                  score*=-1 if score > 0
                  echo("\n[AI - #{Time.now - $time}] Score negated b/c #{PBMoves.getName(move)} will activate #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)}. New score: #{score}.")
                end
              end
            end
            # Innards Out
            if target.hasActiveAbility?(:INNARDSOUT) && knocksOut?(move,user,target,skill,move.baseDamage) &&
               !user.hasActiveAbility?(:MAGICGUARD)
              if move.multiHitMove?
                score*=2
                echo("\n[AI - #{Time.now - $time}] Score x2 b/c #{user.pbThis(true)}'s multi-hit move #{PBMoves.getName(move)} knocks out #{target.pbThis(true)} who has #{PBAbilities.getName(target.ability)}. New score: #{score}.")
              elsif user.hp < target.hp
                score*=0.5
                echo("\n[AI - #{Time.now - $time}] Score x0.5 b/c #{user.pbThis(true)} will get knocked out when #{PBMoves.getName(move)} knocks out #{target.pbThis(true)} who has #{PBAbilities.getName(target.ability)}. New score: #{score}.")
              end
            end
            # Justified
            if target.hasActiveAbility?(:JUSTIFIED) && pbRoughType(move,user,skill) == PBTypes::DARK &&
               !knocksOut?(move,user,target,skill,move.baseDamage) && target.physicalAttacker? &&
               target.canRaiseStatStage?(PBStats::ATTACK)
              if target.opposes?(user)
                score*=-1 if score > 0
                score*=(0.5/move.pbNumHits(user,target))
                echo("\n[AI - #{Time.now - $time}] Score x#{(0.5/move.pbNumHits(user,target))} b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} will trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)}. New score: #{score}.")
              end
            end
            # Rattled
            if target.hasActiveAbility?(:RATTLED) && (pbRoughType(move,user,skill) == PBTypes::DARK ||
               pbRoughType(move,user,skill) == PBTypes::BUG || pbRoughType(move,user,skill) == PBTypes::GHOST) &&
               !knocksOut?(move,user,target,skill,move.baseDamage) && target.canRaiseStatStage?(PBStats::SPEED)
              if user.isFasterThan(target)
                score*=0.3
                echo("\n[AI - #{Time.now - $time}] Score x0.3 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} will trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and it is faster. New score: #{score}.")
              else
                score*=0.8
                echo("\n[AI - #{Time.now - $time}] Score x0.8 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} will trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and it is slower. New score: #{score}.")
              end
            end
            # Stamina
            if target.hasActiveAbility?(:STAMINA) && !knocksOut?(move,user,target,skill,move.baseDamage) && 
               target.canRaiseStatStage?(PBStats::DEFENSE)
              if pbRoughStat(user,PBStats::ATTACK,skill) > pbRoughStat(user,PBStats::SPATK,skill)
                score*=0.3
                echo("\n[AI - #{Time.now - $time}] Score x0.3 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} will trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and it is a physical attacker. New score: #{score}.")
              else
                score*=0.9
                echo("\n[AI - #{Time.now - $time}] Score x0.9 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} will trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and it is not a physical attacker. New score: #{score}.")
              end
            end
            # Water Compaction
            if target.hasActiveAbility?(:WATERCOMPACTION) && !knocksOut?(move,user,target,skill,move.baseDamage) && 
               target.canRaiseStatStage?(PBStats::DEFENSE) && pbRoughType(move,user,skill) == PBTypes::WATER
              if pbRoughStat(user,PBStats::ATTACK,skill) > pbRoughStat(user,PBStats::SPATK,skill)
                score*=0.3
                echo("\n[AI - #{Time.now - $time}] Score x0.3 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} will trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and it is a physical attacker. New score: #{score}.")
              else
                score*=0.9
                echo("\n[AI - #{Time.now - $time}] Score x0.9 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} will trigger #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and it is not a physical attacker. New score: #{score}.")
              end
            end
            # Weak Armor
            if target.hasActiveAbility?(:WEAKARMOR) && !knocksOut?(move,user,target,skill,move.baseDamage,false,true) &&
               move.physicalMove?
              if target.canRaiseStatStage?(PBStats::SPEED)
                if user.isFasterThan(target)
                  score*=0.3
                  echo("\n[AI - #{Time.now - $time}] Score x0.3 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} triggers #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} who is faster than the user. New score: #{score}.")
                end
              end
              if target.canLowerStatStage?(PBStats::DEFENSE) && pbRoughStat(user,PBStats::ATTACK,skill) > pbRoughStat(user,PBStats::SPATK,skill)
                score*=1.3
                echo("\n[AI - #{Time.now - $time}] Score x1.3 b/c #{user.pbThis(true)}'s #{PBMoves.getName(move)} triggers #{target.pbThis(true)}'s #{PBAbilities.getName(target.ability)} and its Attack is higher than Sp. Atk. New score: #{score}.")
              end
            end
          end
          # Decrease score for status moves when there are excellent damaging moves
          if move.baseDamage==0
            greatmoves=false
            if initialscores.length>0
              for i in 0...initialscores.length
                next if i==scoreindex
                if initialscores[i]>=100
                  greatmoves=true
                end
              end
            end          
            if greatmoves
              maxdam=0
              if skill>=PBTrainerAI.bestSkill
                if @aiMoveMemory[target.pokemonIndex].length>0              
                  for j in @aiMoveMemory[target.pokemonIndex]
                    tempdam = pbRoughDamage(j,target,user,skill,j.baseDamage,false,false,false)
                    maxdam=tempdam if tempdam>maxdam
                  end                
                end      
              end            
              if maxdam>(user.hp*0.3) || favorableTypeMatchUp(target,user)
                score*=0.3
                echo("\n[AI - #{Time.now - $time}] Score x0.3 b/c #{target.pbThis(true)} can do more than 1/3 damage to #{user.pbThis(true)}, who has a good move, or it has a type advantage. New score: #{score}.")
              end                                    
            end        
          end    
          # Prefer damaging moves if AI has no more Pokémon or AI is less clever
          if @battle.pbAbleNonActiveCount(user.idxOwnSide)==0
            if skill>=PBTrainerAI.mediumSkill && !(skill>=PBTrainerAI.highSkill && 
               @battle.pbAbleNonActiveCount(target.idxOwnSide)>0)
              if move.statusMove?
                score*=0.9
                echo("\n[AI - #{Time.now - $time}] Score x0.9 b/c #{PBMoves.getName(move)} is status, and #{user.pbThis(true)} is faster and is the last Pokemon, or the AI is less clever. New score: #{score}.")
              elsif target.hp<=target.totalhp/2
                score *= 1.1
                echo("\n[AI - #{Time.now - $time}] Score x1.1 b/c #{PBMoves.getName(move)} is damaging, and #{user.pbThis(true)} is below or at half HP. New score: #{score}.")
              end
            end
          end
          # Don't prefer attacking the target if it'd be semi-invulnerable
          if skill>=PBTrainerAI.highSkill && move.accuracy>0 && (target.semiInvulnerable? || 
             target.effects[PBEffects::SkyDrop]>=0)
            miss = true
            miss = false if user.hasActiveAbility?(:NOGUARD) || target.hasActiveAbility?(:NOGUARD)
            if miss
              if skill>=PBTrainerAI.bestSkill
                # Knows what can get past semi-invulnerability
                if target.effects[PBEffects::SkyDrop]>=0
                  miss = false if move.hitsFlyingTargets?
                else
                  if target.inTwoTurnAttack?("0C9","0CC","0CE")   # Fly, Bounce, Sky Drop
                    miss = false if move.hitsFlyingTargets?
                  elsif target.inTwoTurnAttack?("0CA")          # Dig
                    miss = false if move.hitsDiggingTargets?
                  elsif target.inTwoTurnAttack?("0CB")          # Dive
                    miss = false if move.hitsDivingTargets?
                  end
                end
              end
            end
            if miss && user.isFasterThan(target)
              echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{PBMoves.getName(move)} will supposedly miss #{target.pbThis(true)}, who is slower than #{user.pbThis(true)}.")
              return 0
            end
          end
          # Pick a good move for the Choice items
          if user.hasActiveItem?([:CHOICEBAND,:CHOICESPECS,:CHOICESCARF])
            if move.baseDamage == 0
              if move.function!="0F2" # Trick, Switcheroo (score modifications handled in move effect score)
                echo("\n[AI - #{Time.now - $time}] Score x0 b/c #{user.pbThis(true)} is holding a #{PBItems.getName(user.item)} and #{PBMoves.getName(move)} is not damaging.")
                return 0
              end
            else
              mult=1.5*move.baseDamage/highestBaseDamage(user) # Doesn't like fixed damage moves
              score*=mult
              echo("\n[AI - #{Time.now - $time}] Score x#{mult}, scaling with #{PBMoves.getName(move)}'s highest damage move. New score: #{score}.")
            end
          end
          # If user is asleep, prefer moves that are usable while asleep
          if user.asleep? && !move.usableWhenAsleep? && user.statusCount != 1 # Will wake up next turn
            hasSleepMove = false
            user.eachMove do |m|
              next unless m.usableWhenAsleep?
              hasSleepMove = true
              break
            end
            if hasSleepMove
              score*=0.3
              echo("\n[AI - #{Time.now - $time}] Score x0.3 b/c #{PBMoves.getName(move)} can't be used while asleep, and #{user.pbThis(true)} has a move that can be. New score: #{score}.")
            end
          end
          # If user is not asleep, don't prefer moves only usable while asleep
          if (!user.asleep? || user.statusCount == 1) && move.usableWhenAsleep?
            echo("\n[AI - #{Time.now - $time}] Score set to 0 b/c #{PBMoves.getName(move)} can only be used while asleep, and #{user.pbThis(true)} is not asleep or will wake up this turn. New score: #{score}.")
          end
          # If user is frozen, prefer a move that can thaw the user
          if user.frozen?
            if move.thawsUser?
              score*=2
              echo("\n[AI - #{Time.now - $time}] Score x2 b/c #{PBMoves.getName(move)} will thaw #{user.pbThis(true)}. New score: #{score}.")
            end
          end
          # If target is frozen, don't prefer moves that could thaw them
          if target.frozen?
            if pbRoughType(move,user,skill) == PBTypes::FIRE || NEWEST_BATTLE_MECHANICS && 
               move.thawsUser?
              if !knocksOut?(move,user,target,skill,move.baseDamage)
                score*=0.5
                echo("\n[AI - #{Time.now - $time}] Score x0.5 b/c #{PBMoves.getName(move)} will thaw #{target.pbThis(true)}. New score: #{score}.")
              end
            end
          end
          # If target has Substitute active, prefer moves that ignore it
          if target.effects[PBEffects::Substitute] > 0 && move.ignoresSubstitute?(user)
            score *= 2
            echo("\n[AI - #{Time.now - $time}] Score x2 b/c #{PBMoves.getName(move)} ignores #{target.pbThis(true)}'s Substitute. New score: #{score}.")
          end
          # Adjust score based on how much damage it can deal
          if move.damagingMove?
            score = pbGetMoveScoreDamage(score,move,user,target,skill)
          else   # Status moves
            score = pbCheckMoveImmunity(score,move,user,target,skill)
            # Account for accuracy of move (done in pbRoughDamage for damaging)
            accuracy = pbRoughAccuracy(move,user,target,skill)
            score *= accuracy/100.0
          end
  =end
          echo("\n[AI - #{Time.now - $time}] Pre-PP Calc score: #{score}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          if realMove.total_pp == 0
            ppMult = 1.0
          else
            ppMult = 0.7 + 0.3*(realMove.pp/realMove.total_pp)
          end
          score *= ppMult
          score = score.to_i
          echo("\n[AI - #{Time.now - $time}] PP Score mult: #{ppMult}. Final score: #{score}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        else
          echo("\n[AI - #{Time.now - $time}] Score is 0 because #{callMove.name} won't do anything useful or harmful.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
      end
      return score
    end
  
    #=============================================================================
    # Add to a move's score based on how much damage it will deal (as a percentage
    # of the target's current HP)
    #=============================================================================
    # Return a score based on how much damage a move deals to a given target as well as its accuracy
    def pbGetMoveScoreDamage(callMove,realMove,user,target,damage)
      return 0 if damage == 0
      if target.nil?
        acc = callMove.accuracy / 100.0
        return (acc * 100 / (user.hp / damage)).round # Assumes user HP similar to other battlers
      else
        acc = pbRoughAccuracy(callMove,realMove,user,target) / 100.0
        return (acc * 100 / (target.hp / damage)).round # Based on number of hits to KO
      end
    end
  end
  