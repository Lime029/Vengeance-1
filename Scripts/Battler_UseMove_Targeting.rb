class PokeBattle_Battler
    #=============================================================================
    # Get move's user
    #=============================================================================
    def pbFindUser(_choice,_move)
      return self
    end
  
    def pbChangeUser(choice,move,user)
      # Snatch
      move.snatched = false
      if move.canSnatch?
        newUser = nil; strength = 100
        @battle.eachBattler do |b|
          next if b.effects[PBEffects::Snatch]==0 ||
                  b.effects[PBEffects::Snatch]>=strength
          next if b.effects[PBEffects::SkyDrop]>=0
          newUser = b
          strength = b.effects[PBEffects::Snatch]
        end
        if newUser
          user = newUser
          user.effects[PBEffects::Snatch] = 0
          move.snatched = true
          @battle.moldBreaker = user.hasMoldBreaker?
          choice[3] = -1   # Clear pre-chosen target
        end
      end
      return user
    end
  
    #=============================================================================
    # Get move's default target(s)
    #=============================================================================
    def pbFindTargets(choice,move,user)
      preTarget = choice[3]   # A target that was already chosen
      targets = []
      target = move.pbTarget(user).id
      # Get list of targets
      case $fefieldeffect
      when 1 # Electric Terrain
        if move.id == :THUNDERWAVE
          target = :AllNearOthers
        end
      when 2 # Grassy Terrain
        if [:YAWN,:INFERNO].include?(move.id)
          target = :AllNearOthers
        end
      when 4 # Dark Crystal Cavern
        if move.id == :PRISMATICLASER || user.effects[PBEffects::NeverMiss]
          target = :AllNearFoes
        end
      when 5 # Chess Board
        if [:TAUNT,:TORMENT].include?(move.id)
          target = :AllNearFoes
        end
      when 6 # Performance Stage
        if move.soundMove?(user) && [:NearFoe,:RandomNearFoe,:Foe,:NearOther,:Other].include?(target)
          target = :AllFoes
        end
      when 7 # Volcanic Field
        if [:ERUPTION,:INFERNO].include?(move.id)
          target = :AllNearOthers
        end
      when 9 # Rainbow Field
        if move.function == "190" # Expanding Force
          target = :AllNearFoes
        end
      when 11 # Corrosive Mist Field
        if move.id == :ACIDSPRAY
          target = :AllNearFoes
        end
      when 15 # Forest Field
        if move.specialMove? && move.pbCalcTypes(user).include?(:BUG) && [:NearFoe,:RandomNearFoe,:Foe,:NearOther,:Other].include?(target)
          target = :AllNearFoes
        end
      when 22 # Underwater
        if move.pbCalcTypes(user).include?(:ELECTRIC) && move.damagingMove?
          target = :AllNearOthers
        end
      when 23 # Cave
        if move.soundMove?(user) && [:NearFoe,:RandomNearFoe,:Foe,:NearOther,:Other].include?(target)
          target = :AllFoes
        end
      when 25 # Crystal Cavern
        if user.effects[PBEffects::NeverMiss]
          target = :AllNearFoes
        end
      when 29 # Holy Field
        if move.function == "190" # Expanding Force
          target = :AllNearFoes
        end
      when 30 # Mirror Arena
        if [:FLASHCANNON,:LUSTERPURGE,:PRISMATICLASER,:SOLARBEAM,:LIGHTOFRUIN,:PHOTONGEYSER,
           :LIGHTTHATBURNSTHESKY,:GENESISSUPERNOVA,:LUMINOUSBLADE].include?(move.id)
          target = :AllNearFoes
        end
      when 32 # Dragon's Den
        if move.id == :MEANLOOK
          target = :AllFoes
        end
      when 33 # Flower Garden Field
        if ($fecounter == 4 && move.powderMove? || $fecounter >= 3 && [:PETALDANCE,
           :PETALBLIZZARD,:FAIRYWIND,:SILVERWIND].include?(move.id)) &&
           [:NearFoe,:RandomNearFoe,:Foe,:NearOther,:Other].include?(target)
          target = :AllNearFoes
        end
      when 34 # Starlight Arena
        if move.function == "190" # Expanding Force
          target = :AllNearFoes
        end
      when 37 # Psychic Terrain
        if move.function == "190" || @id == :PSYWAVE # Expanding Force
          target = :AllNearFoes
        end
      when 38 # Dimensional Field
        if move.function == "190" # Expanding Force
          target = :AllNearFoes
        end
      when 44 # Indoors
        if [:SMOG,:POISONGAS,:SMOKESCREEN,:AROMATICMIST].include?(@id)
          target = :AllNearOthers
        end
      end
      case target  # Curse can change its target type
      when :NearAlly
        targetBattler = (preTarget>=0) ? @battle.battlers[preTarget] : nil
        if !pbAddTarget(targets,user,targetBattler,move)
          pbAddTargetRandomAlly(targets,user,move)
        end
      when :UserOrNearAlly
        targetBattler = (preTarget>=0) ? @battle.battlers[preTarget] : nil
        if !pbAddTarget(targets,user,targetBattler,move,true,true)
          pbAddTarget(targets,user,user,move,true,true)
        end
      when :UserAndAllies
        pbAddTarget(targets,user,user,move,true,true)
        @battle.eachSameSideBattler(user.index) { |b| pbAddTarget(targets,user,b,move,false,true) }
      when :NearFoe, :NearOther
        targetBattler = (preTarget>=0) ? @battle.battlers[preTarget] : nil
        if !pbAddTarget(targets,user,targetBattler,move)
          if preTarget>=0 && !user.opposes?(preTarget)
            pbAddTargetRandomAlly(targets,user,move)
          else
            pbAddTargetRandomFoe(targets,user,move)
          end
        end
      when :RandomNearFoe
        pbAddTargetRandomFoe(targets,user,move)
      when :AllNearFoes
        @battle.eachOtherSideBattler(user.index) { |b| pbAddTarget(targets,user,b,move) }
      when :Foe, :Other
        targetBattler = (preTarget>=0) ? @battle.battlers[preTarget] : nil
        if !pbAddTarget(targets,user,targetBattler,move,false)
          if preTarget>=0 && !user.opposes?(preTarget)
            pbAddTargetRandomAlly(targets,user,move,false)
          else
            pbAddTargetRandomFoe(targets,user,move,false)
          end
        end
      when :AllFoes
        @battle.eachOtherSideBattler(user.index) { |b| pbAddTarget(targets,user,b,move,false) }
      when :AllNearOthers
        @battle.eachBattler { |b| pbAddTarget(targets,user,b,move) }
      when :AllBattlers
        @battle.eachBattler { |b| pbAddTarget(targets,user,b,move,false,true) }
      else
        # Used by Counter/Mirror Coat/Metal Burst/Bide
        move.pbAddTarget(targets,user)   # Move-specific pbAddTarget, not the def below
      end
      # More complex target modifiers
      case $fefieldeffect
      when 21 # Water Surface
        if move.pbCalcTypes(user).include?(:ELECTRIC) && move.damagingMove? && target != :AllNearOthers
          groundedTarget = false
          for b in targets
            if b.grounded?
              groundedTarget = true
            end
          end
          if groundedTarget
            @battle.eachBattler do |b|
              pbAddTarget(targets,user,b,move,false) if b.grounded? && !targets.include?(b)
            end
          end
        end
      end
      return targets
    end
  
    #=============================================================================
    # Redirect attack to another target
    #=============================================================================
    def pbChangeTargets(move,user,targets,dragondarts=-1)
      target_data = move.pbTarget(user)
      return targets if @battle.switching   # For Pursuit interrupting a switch
      return targets if move.cannotRedirect?
      return targets if move.function != "17C" && !target_data.can_target_one_foe? || targets.length != 1
      # Stalwart / Propeller Tail
      allySwitched = false
      ally = -1
      user.eachOpposing do |b|
        next if !b.lastMoveUsed
        next if GameData::Move.get(b.lastMoveUsed).function_code != "120"
        next if !target_data.can_target_one_foe?
        next if (!user.hasActiveAbility?(:STALWART) || $fefieldeffect == 39) && (!user.hasActiveAbility?(:PROPELLERTAIL) ||
                $fefieldeffect == 8 && user.grounded?) && move.function != "182" # Snipe Shot
        next if !@battle.choices[b.index][3] == targets
        next if b.effects[PBEffects::SwitchedAlly] == -1
        allySwitched = !allySwitched
        ally = b.effects[PBEffects::SwitchedAlly]
        b.effects[PBEffects::SwitchedAlly] = -1
      end
      if allySwitched && ally >= 0
        targets = []
        pbAddTarget(targets,user,@battle.battlers[ally],move,move.target.can_target_one_foe?)
        return targets
      end
      return targets if user.hasActiveAbility?(:STALWART) && $fefieldeffect != 39 || 
                        user.hasActiveAbility?(:PROPELLERTAIL) && !($fefieldeffect == 8 &&
                        user.grounded?)
        return targets if move.function == "182"
      priority = @battle.pbPriority(true)
      nearOnly = !target_data.can_choose_distant_target?
      # Spotlight (takes priority over Follow Me/Rage Powder/Lightning Rod/Storm Drain)
      newTarget = nil; strength = 100   # Lower strength takes priority
      priority.each do |b|
        next if b.fainted? || b.effects[PBEffects::SkyDrop]>=0
        next if b.effects[PBEffects::Spotlight]==0 ||
                b.effects[PBEffects::Spotlight]>=strength
        next if !b.opposes?(user)
        next if nearOnly && !b.near?(user)
        newTarget = b
        strength = b.effects[PBEffects::Spotlight]
      end
      if newTarget
        PBDebug.log("[Move target changed] #{newTarget.pbThis}'s Spotlight made it the target")
        targets = []
        pbAddTarget(targets,user,newTarget,move,nearOnly)
        return targets
      end
      # Follow Me/Rage Powder (takes priority over Lightning Rod/Storm Drain)
      newTarget = nil; strength = 100   # Lower strength takes priority
      priority.each do |b|
        next if b.fainted? || b.effects[PBEffects::SkyDrop]>=0
        next if b.effects[PBEffects::RagePowder] && !user.affectedByPowder?
        next if b.effects[PBEffects::FollowMe]==0 ||
                b.effects[PBEffects::FollowMe]>=strength
        next if !b.opposes?(user)
        next if nearOnly && !b.near?(user)
        newTarget = b
        strength = b.effects[PBEffects::FollowMe]
      end
      if newTarget
        PBDebug.log("[Move target changed] #{newTarget.pbThis}'s Follow Me/Rage Powder made it the target")
        targets = []
        pbAddTarget(targets,user,newTarget,move,nearOnly)
        return targets
      end
      # Dragon Darts redirection
      if dragondarts>=0
        newTargets=[]
        neednewtarget=false
        # Check if first use has to be redirected
        if dragondarts==0
          targets.each do |b|
            next if !b.effects[PBEffects::Protect] && !(b.effects[PBEffects::QuickGuard] && 
                    @battle.choices[user.index][4]>0) && !b.effects[PBEffects::SpikyShield] && 
                    !b.effects[PBEffects::BanefulBunker] && !b.effects[PBEffects::Obstruct] && 
                    b.effects[PBEffects::TwoTurnAttack].nil? && !move.pbImmunityByAbility(user,b) && 
                    !Effectiveness.ineffective_type?(move.types,b.type1,b.type2) &&
                    move.pbAccuracyCheck(user,b)
            neednewtarget = true
            next
          end
        end
        # Redirect first use if necessary or get another target on each consecutive use
        if neednewtarget || dragondarts==1
          targets[0].eachAlly do |b|
            next if b.index == user.index && dragondarts==1 # Don't attack yourself on the second hit.
            next if b.effects[PBEffects::Protect] ||
            (b.effects[PBEffects::QuickGuard] && @battle.choices[user.index][4]>0) ||
            b.effects[PBEffects::SpikyShield] ||
            b.effects[PBEffects::BanefulBunker] ||
            b.effects[PBEffects::Obstruct] ||
            b.effects[PBEffects::TwoTurnAttack]>0||
            move.pbImmunityByAbility(user,b) ||
            Effectiveness.ineffective_type?(move.types,b.type1,b.type2) ||
            !move.pbAccuracyCheck(user,b)
            newTargets.push(b)
            b.damageState.unaffected = false
            # In double battle, the pokémon might keep this state from a hit from the ally.
            break
          end
        end
        # Final target
        targets=newTargets if newTargets.length!=0
        # Reduce PP if the new target has Pressure
        if targets[0].hasActiveAbility?(:PRESSURE) && ![20,48].include?($fefieldeffect)
          user.pbReducePP(move) # Reduce PP
          user.pbReducePP(move) if [5,6,32,38,45].include?($fefieldeffect)
        end
        if targets[0].hasActiveAbility?([:UNNERVE,:ARENATRAP]) && $fefieldeffect == 5
          user.pbReducePP(move) # Reduce PP
        end
      end
      # Willpower
      if targets.length <= 1 && user.effects[PBEffects::Willpower] && targets[0].index != user.index
        allies = []
        user.eachNearAlly do |b|
          allies.push(b)
        end
        chosenAlly = allies[rand(allies.length)]
        if @battle.pbMoveCanTarget?(user.index,chosenAlly.index,target_data)
          targets.clear
          pbAddTarget(targets,user,chosenAlly,move)
        end
      end
      # Lightning Rod
      targets = pbChangeTargetByAbility(:LIGHTNINGROD,:ELECTRIC,move,user,targets,priority,nearOnly) if ![15,22,42,47].include?($fefieldeffect)
      # Storm Drain
      targets = pbChangeTargetByAbility(:STORMDRAIN,:WATER,move,user,targets,priority,nearOnly) if $fefieldeffect != 22
      # Bearded Magnetism
      targets = pbChangeTargetByAbility(:BEARDEDMAGNETISM,:GROUND,move,user,targets,priority,nearOnly)
      return targets
    end
  
    def pbChangeTargetByAbility(drawingAbility,drawnType,move,user,targets,priority,nearOnly)
      return targets if !move.calcTypes.include?(drawnType)
      return targets if targets[0].hasActiveAbility?(drawingAbility)
      priority.each do |b|
        next if b.index==user.index || b.index==targets[0].index
        next if !b.hasActiveAbility?(drawingAbility)
        next if nearOnly && !b.near?(user)
        @battle.pbShowAbilitySplash(b)
        targets.clear
        pbAddTarget(targets,user,b,move,nearOnly)
        user.effects[PBEffects::AbilityTypeRedirect] = true
        break
      end
      return targets
    end
  
    #=============================================================================
    # Register target
    #=============================================================================
    def pbAddTarget(targets,user,target,move,nearOnly=true,allowUser=false)
      return false if !target || (target.fainted? && !move.cannotRedirect?)
      return false if !(allowUser && user==target) && nearOnly && !user.near?(target)
      targets.each { |b| return true if b.index==target.index }   # Already added
      targets.push(target)
      return true
    end
  
    def pbAddTargetRandomAlly(targets,user,_move,nearOnly=true)
      choices = []
      user.eachAlly do |b|
        next if nearOnly && !user.near?(b)
        pbAddTarget(choices,user,b,nearOnly)
      end
      if choices.length>0
        pbAddTarget(targets,user,choices[@battle.pbRandom(choices.length)],nearOnly)
      end
    end
  
    def pbAddTargetRandomFoe(targets,user,_move,nearOnly=true)
      choices = []
      user.eachOpposing do |b|
        next if nearOnly && !user.near?(b)
        pbAddTarget(choices,user,b,nearOnly)
      end
      if choices.length>0
        pbAddTarget(targets,user,choices[@battle.pbRandom(choices.length)],nearOnly)
      end
    end
  end
  