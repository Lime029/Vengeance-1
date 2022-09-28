class PokeBattle_Move
    #=============================================================================
    # Effect methods per move usage
    #=============================================================================
    def pbCanChooseMove?(user,commandPhase,showMessages); return true; end   # For Belch
    def pbDisplayChargeMessage(user); end   # For Focus Punch/shell Trap/Beak Blast
    def pbOnStartUse(user,targets); end
    def pbAddTarget(targets,user); end      # For Counter, etc. and Bide
  
    # Reset move usage counters (child classes can increment them).
    def pbChangeUsageCounters(user,specialUsage)
      user.effects[PBEffects::FuryCutter]   = 0
      user.effects[PBEffects::ParentalBond] = 0
      user.effects[PBEffects::HitsTwice]    = 0
      user.effects[PBEffects::ProtectRate]  = 1
      @battle.field.effects[PBEffects::FusionBolt]  = false
      @battle.field.effects[PBEffects::FusionFlare] = false
    end
  
    def pbDisplayUseMessage(user)
      @battle.pbDisplayBrief(_INTL("{1} used {2}!",user.pbThis,@name))
    end
  
    def pbMissMessage(user,target); return false; end
  
    #=============================================================================
    #
    #=============================================================================
    # Whether the move is currently in the "charging" turn of a two turn attack.
    # Is false if Power Herb or another effect lets a two turn move charge and
    # attack in the same turn.
    # user.effects[PBEffects::TwoTurnAttack] is set to the move's ID during the
    # charging turn, and is nil during the attack turn.
    def pbIsChargingTurn?(user); return false; end
    def pbDamagingMove?; return damagingMove?; end
  
    def pbContactMove?(user)
      return false if user.hasActiveAbility?(:LONGREACH) && $fefieldeffect != 22 || 
                      user.hasActiveItem?(:PROTECTIVEPADS)
      return contactMove?
    end
  
    # The maximum number of hits in a round this move will actually perform. This
    # can be 1 for Beat Up, and can be 2 for any moves affected by Parental Bond.
    def pbNumHits(user,targets)
      ret = 1
      if (user.hasActiveAbility?(:PARENTALBOND) && $fefieldeffect != 35 || user.hasActiveAbility?(:SHADOWTAG) &&
         [18,40].include?($fefieldeffect)) && pbDamagingMove? && !chargingTurnMove? && 
         targets.length==1
        # Record that Parental Bond applies, to weaken the second attack
        user.effects[PBEffects::ParentalBond] = 3
        ret += 1
      end
      if $fefieldeffect == 34 && [:HASTY,:LAX].include?(user.pokemon.nature_id) &&
         pbDamagingMove? && !chargingTurnMove?
        user.effects[PBEffects::HitsTwice] = 3
        ret += 1
      end
      return ret
    end
  
    #=============================================================================
    # Effect methods per hit
    #=============================================================================
    def pbOverrideSuccessCheckPerHit(user,target); return false; end
    def pbCrashDamage(user); end
      
    def pbInitialEffect(user,targets,hitNum)
      if user.hasActiveAbility?(:ALPHABETIZATION)
        if user.checkAlphabetizationForm(17) && target.tookDamage
          @battle.pbDisplay(_INTL("{1}'s {2} (Reassure) activated!",user.pbThis,user.abilityName))
          target.pbCheckAndInflictRandomStatus(user,true)
        end
        if user.checkAlphabetizationForm(18) && Effectiveness.super_effective?(target.damageState.typeMod)
          if target.pbLowerStatStageByCause([:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED,:ACCURACY,:EVASION],12,user,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} (Search) minimized all of {3}'s stats!",user.pbThis,user.abilityName,target.pbThis(true)))
          end
        end
      end
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      return if !showAnimation
      if user.effects[PBEffects::HitsTwice]==1
        hitNum = 0
      end
      if user.effects[PBEffects::ParentalBond]==1
        @battle.pbCommonAnimation("ParentalBond",user,targets)
      else
        @battle.pbAnimation(id,user,targets,hitNum)
      end
    end
  
    def pbSelfKO(user); end
    def pbEffectWhenDealingDamage(user,target); end
    def pbEffectAgainstTarget(user,target); end
    def pbEffectGeneral(user); end
    def pbAdditionalEffect(user,target); end
    def pbEffectAfterAllHits(user,target); end   # Move effects that occur after all hits
    def pbSwitchOutTargetsEffect(user,targets,numHits,switchedBattlers); end
    def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers); end
  
    #=============================================================================
    # Check if target is immune to the move because of its ability
    #=============================================================================
    def pbImmunityByAbility(user,target)
      return false if @battle.moldBreaker
      #ret = BattleHandlers.triggerMoveImmunityTargetAbility(target.ability,user,target,self,@calcType,@battle)
      ret = false
      if user.index != target.index
        if @calcTypes.include?(:FIRE)
          if target.hasActiveAbility?(:FLASHFIRE) && $fefieldeffect != 39
            @battle.pbShowAbilitySplash(target)
            if !target.effects[PBEffects::FlashFire]
              target.effects[PBEffects::FlashFire] = true
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!",target.pbThis(true)))
              else
                @battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose because of its {2}!",target.pbThis(true),target.abilityName))
              end
            else
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
              else
                @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
              end
            end
            @battle.pbHideAbilitySplash(target)
            ret = true
          end
          if target.hasActiveAbility?(:HEATPROOF)
            if [8,21,26].include?($fefieldeffect)
              @battle.pbDisplay(_INTL("The wet surrounding makes {1}'s {2} provide immunity to Fire moves!",target.pbThis(true),target.abilityName))
              ret = true
            elsif [13,28,39,46].include?($fefieldeffect)
              @battle.pbDisplay(_INTL("The cold surrounding makes {1}'s {2} provide immunity to Fire moves!",target.pbThis(true),target.abilityName))
              ret = true
            end
          end
        end
        if @calcTypes.include?(:ELECTRIC)
          if target.hasActiveAbility?(:LIGHTNINGROD) && $fefieldeffect != 22
            @battle.pbShowAbilitySplash(target)
            if user.effects[PBEffects::AbilityTypeRedirect]
              user.effects[PBEffects::AbilityTypeRedirect] = false
              @battle.pbDisplay(_INTL("{1} took the attack with its {2}!",target.pbThis,target.abilityName))
            end
            if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
              if [1,17,18,21,27,43].include?($fefieldeffect)
                increment = 2
              else
                increment = 1
              end
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                target.pbRaiseStatStage(:SPECIAL_ATTACK,increment,target)
              else
                target.pbRaiseStatStageByCause(:SPECIAL_ATTACK,increment,target,target.abilityName)
              end
            else
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
              else
                @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
              end
            end
            @battle.pbHideAbilitySplash(target)
            ret = true
          end
          if target.hasActiveAbility?(:MOTORDRIVE) && ($fefieldeffect != 18 || @battle.pbRandom(2) == 0) &&
             !($fefieldeffect == 26 && target.grounded?)
            @battle.pbShowAbilitySplash(target)
            if target.pbCanRaiseStatStage?(:SPEED,target)
              if [17,18].include?($fefieldeffect)
                increment = 2
              else
                increment = 1
              end
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                target.pbRaiseStatStage(:SPEED,increment,target)
              else
                target.pbRaiseStatStageByCause(:SPEED,increment,target,target.abilityName)
              end
            else
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
              else
                @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
              end
            end
            @battle.pbHideAbilitySplash(target)
            ret = true
          end
          if target.hasActiveAbility?(:VOLTABSORB)
            @battle.pbShowAbilitySplash(target)
            if $fefieldeffect == 1
              healAmount = target.totalhp
            elsif $fefieldeffect == 17
              healAmount = target.totalhp/3
            else
              healAmount = target.totalhp/4
            end
            if target.canHeal? && target.pbRecoverHP(healAmount)>0
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
              else
                @battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",target.pbThis,target.abilityName))
              end
            else
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
              else
                @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
              end
            end
            @battle.pbHideAbilitySplash(target)
            ret = true
          end
        end
        if @calcTypes.include?(:GRASS) && target.hasActiveAbility?(:SAPSIPPER) &&
           $fefieldeffect != 11
          @battle.pbShowAbilitySplash(target)
          if target.pbCanRaiseStatStage?(:ATTACK,target)
            if $fefieldeffect == 47
              increment = 2
            else
              increment = 1
            end
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              target.pbRaiseStatStage(:ATTACK,increment,target)
            else
              target.pbRaiseStatStageByCause(:ATTACK,increment,target,target.abilityName)
            end
          else
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
            else
              @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
            end
          end
          @battle.pbHideAbilitySplash(target)
          ret = true
        end
        if @calcTypes.include?(:WATER)
          if target.hasActiveAbility?(:STORMDRAIN)
            @battle.pbShowAbilitySplash(target)
            if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
              if [8,21,49].include?($fefieldeffect)
                increment = 2
              else
                increment = 1
              end
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                target.pbRaiseStatStage(:SPECIAL_ATTACK,increment,target)
              else
                target.pbRaiseStatStageByCause(:SPECIAL_ATTACK,increment,target,target.abilityName)
              end
            else
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
              else
                @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
              end
            end
            @battle.pbHideAbilitySplash(target)
            ret = true
          end
          if target.hasActiveAbility?(:WATERABSORB)
            @battle.pbShowAbilitySplash(target)
            if $fefieldeffect == 16
              healAmount = target.totalhp/5
            elsif $fefieldeffect == 49
              healAmount = target.totalhp/2
            else
              healAmount = target.totalhp/4
            end
            if target.canHeal? && target.pbRecoverHP(healAmount)>0
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
              else
                @battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",target.pbThis,target.abilityName))
              end
              if $fefieldeffect == 13 && target.pbCanFreeze?(nil,false)
                target.pbFreeze
              end
            else
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
              else
                @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
              end
            end
            @battle.pbHideAbilitySplash(target)
            ret = true
          end
          if target.hasActiveAbility?(:DRYSKIN)
            @battle.pbShowAbilitySplash(target)
            if target.canHeal? && target.pbRecoverHP(target.totalhp/4)>0
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
              else
                @battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",target.pbThis,target.abilityName))
              end
            else
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
              else
                @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
              end
            end
            @battle.pbHideAbilitySplash(target)
            ret = true
          end
          if target.hasActiveAbility?(:WATERCOMPACTION) && $fefieldeffect == 48
            @battle.pbShowAbilitySplash(target)
            if !target.pbRaiseStatStageByCause([:DEFENSE,:SPECIAL_DEFENSE],2,target,target.abilityName)
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
              else
                @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
              end
            end
            @battle.pbHideAbilitySplash(target)
            ret = true
          end
          if target.pbHasType?(:GRASS) && $fefieldeffect == 49
            if target.canHeal? && target.pbRecoverHP(target.totalhp/4)>0
              @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
            else
              @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
            end
            ret = true
          end
        end
        if @calcTypes.include?(:POISON)
          if target.hasActiveAbility?(:IMMUNITY) && $fefieldeffect == 11
            @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
            ret = true
          end
          if target.hasActiveAbility?(:PASTELVEIL) && $fefieldeffect == 19
            @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
            ret = true
          end
        end
        if @calcTypes.include?(:GROUND) && target.hasActiveAbility?(:BEARDEDMAGNETISM)
          if target.pbCanRaiseStatStage?(:DEFENSE,target)
            if [1,18].include?($fefieldeffect)
              target.pbRaiseStatStageByAbility(:DEFENSE,2,target)
            else
              target.pbRaiseStatStageByAbility(:DEFENSE,1,target)
            end
          else
            @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
          end
          ret = true
        end
        if bombMove?
          if target.hasActiveAbility?(:BULLETPROOF)
            @battle.pbShowAbilitySplash(target)
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
            else
              @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
            end
            @battle.pbHideAbilitySplash(target)
            ret = true
          end
          if target.hasActiveAbility?(:JUGGLING) && (@battle.pbRandom(2) == 0 || $fefieldeffect == 6) &&
             ![8,30].include?($fefieldeffect)
            @battle.pbDisplay(_INTL("{1} juggled the attack back!",target.pbThis))
            target.pbUseMoveSimple(@id)
            ret = true
          end
          if target.hasActiveAbility?(:RECEIVER) && $fefieldeffect == 6 && @battle.pbRandom(2) == 0
            @battle.pbDisplay(_INTL("{1} caught and threw the attack back!",target.pbThis))
            target.pbUseMoveSimple(@id)
            ret = true
          end
        end
        if soundMove?(user) && (target.hasActiveAbility?(:SOUNDPROOF) && !($fefieldeffect == 37 &&
           target.pbHasType?(:PSYCHIC)) || target.hasActiveAbility?(:PUNKROCK) && $fefieldeffect == 6)
          @battle.pbShowAbilitySplash(target)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
          end
          @battle.pbHideAbilitySplash(target)
          ret = true
        end
        if windMove? && target.hasActiveAbility?(:AIRFILTRATION)
          if target.canHeal? && target.pbRecoverHP(target.totalhp/4)>0
            @battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",target.pbThis,target.abilityName))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
          end
          ret = true
        end
        if slashingMove?
          if $fefieldeffect == 31 && target.effects[PBEffects::FairyTaleRoles].include?(4) && 
             @battle.pbRandom(2) == 0
            @battle.pbDisplay(_INTL("{1}'s Fighter role parried and redirected the attack!",target.pbThis))
            target.pbUseMoveSimple(@id)
            ret = true
          end
        end
        if !target.opposes?(user) && damagingMove?
          if target.hasActiveAbility?(:TELEPATHY)
            @battle.pbShowAbilitySplash(target)
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!",target.pbThis(true)))
            else
              @battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon with {2}!",target.pbThis,target.abilityName))
            end
            @battle.pbHideAbilitySplash(target)
            ret = true
          end
          target.eachOwnSideBattler do |b|
            if b.hasActiveAbility?(:LIVEWIRE)
              @battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon with {2}'s {3}!",target.pbThis,b.pbThis(true),b.abilityName))
              ret = true
              break
            end
          end
          if target.hasActiveAbility?(:LIVEWIRE) && @calcTypes.include?(:ELECTRIC)
            target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,target)
          end
        end
        if user.hasActiveAbility?(:ALPHABETIZATION) && user.checkAlphabetizationForm(6) && 
           !target.opposes?(user) && damagingMove?
          if target.canHeal? && target.pbRecoverHP(target.totalhp)>0
            @battle.pbDisplay(_INTL("{1}'s {2} (Give) restored {3}'s HP.",user.pbThis,user.abilityName,target.pbThis(true)))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} (Give) made {3} ineffective!",user.pbThis,user.abilityName,@name))
          end
          if user.item && !user.unlosableItem?(user.item) && !target.item && !target.unlosableItem?(user.item)
            itemName = user.itemName
            target.item = user.item
            @battle.pbDisplay(_INTL("{1} received {2} from {3}!",target.pbThis,itemName,user.pbThis(true)))
            target.pbHeldItemTriggerCheck
          end
          ret = true
        end
        if user.pbHasType?(:BUG) && target.hasActiveAbility?(:FLYTRAP) && (pbContactMove?(user) ||
           [15,47].include?($fefieldeffect)) && $fefieldeffect != 22
          @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",target.pbThis,target.abilityName,@name))
        end
      end
      if (!@calcTypes || !Effectiveness.super_effective?(target.damageState.typeMod)) &&
         damagingMove? && target.hasActiveAbility?(:WONDERGUARD)
        @battle.pbShowAbilitySplash(target)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("{1} avoided damage with {2}!",target.pbThis,target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
        ret = true
      end
      return ret
    end
  
    #=============================================================================
    # Move failure checks
    #=============================================================================
    # Check whether the move fails completely due to move-specific requirements.
    def pbMoveFailed?(user,targets); return false; end
    # Checks whether the move will be ineffective against the target.
    def pbFailsAgainstTarget?(user,target); return false; end
  
    def pbMoveFailedLastInRound?(user)
      unmoved = false
      @battle.eachBattler do |b|
        next if b.index==user.index
        next if @battle.choices[b.index][0]!=:UseMove && @battle.choices[b.index][0]!=:Shift
        next if b.movedThisRound?
        unmoved = true
        break
      end
      if !unmoved
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbMoveFailedTargetAlreadyMoved?(target)
      if (@battle.choices[target.index][0]!=:UseMove &&
         @battle.choices[target.index][0]!=:Shift) || target.movedThisRound?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbMoveFailedAromaVeil?(user,target,showMessage=true)
      return false if @battle.moldBreaker || [8,11,22,26].include?($fefieldeffect)
      if target.hasActiveAbility?(:AROMAVEIL)
        if showMessage
          @battle.pbShowAbilitySplash(target)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
          else
            @battle.pbDisplay(_INTL("{1} is unaffected because of its {2}!",
              target.pbThis,target.abilityName))
          end
          @battle.pbHideAbilitySplash(target)
        end
        return true
      end
      target.eachAlly do |b|
        next if !b.hasActiveAbility?(:AROMAVEIL)
        if showMessage
          @battle.pbShowAbilitySplash(target)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
          else
            @battle.pbDisplay(_INTL("{1} is unaffected because of {2}'s {3}!",
              target.pbThis,b.pbThis(true),b.abilityName))
          end
          @battle.pbHideAbilitySplash(target)
        end
        return true
      end
      return false
    end
    
    # Field Move Fail 1
    def failsDueToField?(user,showMessages=false)
      if !zMove? # Z-Moves always work
        case $fefieldeffect
        when 1 # Electric Terrain
          if [:MEDITATE,:CALMMIND,:LOCKON,:LASERFOCUS].include?(@id)
            @battle.pbDisplay(_INTL("But {1} couldn't stay focused...",user.pbThis(true))) if showMessages
            return true
          end
        when 4 # Dark Crystal Cavern
          if [:LIGHTSCREEN,:SOLARBEAM,:SOLARBLADE].include?(@id)
            @battle.pbDisplay(_INTL("But there wasn't enough light to sustain the attack...")) if showMessages
            return true
          elsif @id == :LOCKON
            @battle.pbDisplay(_INTL("But it's too difficult to see clearly in the dark...")) if showMessages
            return true
          end
        when 6 # Performance Stage
          if @id == :METRONOME && user.stages[:SPEED] < 0
            @battle.pbDisplay(_INTL("But {1} couldn't keep up with the tempo!",user.pbThis(true))) if showMessages
            return true
          end
        when 7 # Volcanic Field
          if [:SEISMICTOSS,:THUNDER,:SKYDROP,:FLYINGPRESS,:DRAGONASCENT].include?(@id)
            @battle.pbDisplay(_INTL("But the cave's ceiling was too low...")) if showMessages
            return true
          elsif [:GRASSWHISTLE,:GROWTH,:COTTONSPORE,:STRINGSHOT,:TOXICTHREAD,:SHEERCOLD,
                :INGRAIN,:LEECHSEED,:SPIDERWEB,:STICKYWEB,:LIFEDEW].include?(@id)
            @battle.pbDisplay(_INTL("But the magma burned away the attack...")) if showMessages
            return true
          elsif @id == :HARDEN
            @battle.pbDisplay(_INTL("But the intense heat makes solidification impossible!")) if showMessages
            return true
          end
        when 8 # Swamp
          if user.grounded?
            if danceMove? && user.stages[:SPEED] < 0
              @battle.pbDisplay(_INTL("But {1} was too deeply sunken into the mud!",user.pbThis(true))) if showMessages
              return true
            elsif [:TAILGLOW,:LUSTERPURGE].include?(@id)
              @battle.pbDisplay(_INTL("But {1} couldn't shine bright while covered in mud...",user.pbThis(true))) if showMessages
              return true
            end
          elsif [:ODORSLEUTH,:SWEETSCENT].include?(@id)
            @battle.pbDisplay(_INTL("But the other smells drowned out the attack!")) if showMessages
            return true
          end
        when 9 # Rainbow Field
          if [:SPITE,:DARKVOID,:SIMPLEBEAM,:CORROSIVEGAS,:NIGHTMARE].include?(@id)
            @battle.pbDisplay(_INTL("But the rainbow's energy nullified the attack!")) if showMessages
            return true
          end
        when 10 # Corrosive Field
          if [:GROWTH,:NATURALGIFT,:ROTOTILLER].include?(@id) || statusMove? && healingMove?
            @battle.pbDisplay(_INTL("But the corrosion nullified the attack!")) if showMessages
            return true
          end
        when 11 # Corrosive Mist Field
          if [:SWEETSCENT,:AROMATHERAPY].include?(@id)
            @battle.pbDisplay(_INTL("But the toxic gas nullified the scent!")) if showMessages
            return true
          end
        when 12 # Desert Field
          if [:MIST,:WATERSPORT,:MISTGUARD,:MISTSLASH].include?(@id)
            @battle.pbDisplay(_INTL("But the dry desert nullified the attack!")) if showMessages
            return true
          elsif @id == :SHEERCOLD
            @battle.pbDisplay(_INTL("But the hot desert nullified the attack!")) if showMessages
            return true
          end
        when 13 # Icy Cave
          if [:SEISMICTOSS,:SKYDROP,:THUNDER,:FLYINGPRESS,:DRAGONASCENT].include?(@id)
            @battle.pbDisplay(_INTL("But the cave's ceiling was too low...")) if showMessages
            return true
          end
        when 16 # Volcanic Top Field
          if @id == :INGRAIN
            @battle.pbDisplay(_INTL("But the roots burned up in the magma!")) if showMessages
            return true
          end
        when 21 # Water Surface
          if [:FISSURE,:BOUNCE,:BULLDOZE,:ROTOTILLER,:GEOMANCY,:LANDSWRATH,:EARTHPOWER,
             :PRECIPICEBLADES,:STOMPINGTANTRUM,:JUMPKICK,:HIGHJUMPKICK].include?(@id)
            @battle.pbDisplay(_INTL("But there was no solid ground from which to attack...")) if showMessages
            return true
          elsif [:INGRAIN,:SPIKES,:TOXICSPIKES].include?(@id)
            @battle.pbDisplay(_INTL("But there was no solid ground on which to base the attack...")) if showMessages
            return true
          elsif [:OVERHEAT,:BURNUP].include?(@id) && user.grounded?
            @battle.pbDisplay(_INTL("But the cool water prevented {1} from heating up...",user.pbThis(true))) if showMessages
            return true
          end
        when 22 # Underwater
          if windMove?
            @battle.pbDisplay(_INTL("But the water prevents airflow...")) if showMessages
            return true
          elsif @calcTypes.include?(:FIRE) && specialMove?
            @battle.pbDisplay(_INTL("But the attack was doused instantly...")) if showMessages
            return true
          elsif powderMove? || [:SANDATTACK,:POLLENPUFF,:SCORCHINGSANDS,:DUSTSTORM,
                :MIST,:SMOKESCREEN,:HAZE,:SMOG,:POISONGAS,:SANDTOMB,:STRANGESTEAM,:CORROSIVEGAS,
                :FIERYWRATH,:MISTGUARD,:MISTYEXPLOSION,:INFERNALPARADE].include?(@id)
            @battle.pbDisplay(_INTL("But the water washed away the attack...")) if showMessages
            return true
          elsif [:BLIZZARD,:POWDERSNOW].include?(@id)
            @battle.pbDisplay(_INTL("But the weather stayed above the surface...")) if showMessages
            return true
          elsif [:AROMATHERAPY,:PHEROMONESIGNAL,:SWEETSCENT].include?(@id)
            @battle.pbDisplay(_INTL("But the scent was undetectable...")) if showMessages
            return true
          end
        when 23 # Cave
          if [:SEISMICTOSS,:SKYDROP,:THUNDER,:FLYINGPRESS,:DRAGONASCENT].include?(@id)
            @battle.pbDisplay(_INTL("But the cave's ceiling was too low...")) if showMessages
            return true
          elsif [:SOLARBEAM,:SOLARBLADE].include?(@id)
            @battle.pbDisplay(_INTL("But there wasn't enough light in the cave...")) if showMessages
            return true
          end
        when 26 # Murkwater Surface
          if [:FISSURE,:BOUNCE,:EARTHQUAKE,:BULLDOZE,:ROTOTILLER,:GEOMANCY,:LANDSWRATH,
             :PRECIPICEBLADES,:STOMPINGTANTRUM,:JUMPKICK,:HIGHJUMPKICK,:MAGNITUDE,:EARTHPOWER].include?(@id)
            @battle.pbDisplay(_INTL("But there was no solid ground from which to attack...")) if showMessages
            return true
          elsif [:INGRAIN,:SPIKES,:TOXICSPIKES].include?(@id)
            @battle.pbDisplay(_INTL("But there was no solid ground on which to base the attack...")) if showMessages
            return true
          end
        when 29 # Holy Field
          if @id == :MEFIRST
            @battle.pbDisplay(_INTL("But the lord always comes first!")) if showMessages
            return true
          elsif [:TAUNT,:TORMENT,:ATTRACT,:RAGEPOWDER].include?(@id)
            @battle.pbDisplay(_INTL("...And lead us not into temptation, but deliver us from evil!")) if showMessages
            return true
          end
        when 35 # Ultra Space
          if windMove?
            @battle.pbDisplay(_INTL("But the infinite space swallowed up the wind...")) if showMessages
            return true
          elsif [:EARTHQUAKE,:FISSURE,:DIG,:MAGNITUDE,:BULLDOZE,:SPIKES,:TOXICSPIKES,
                :STICKYWEB,:TECTONICRAGE].include?(@id)
            @battle.pbDisplay(_INTL("But there was no connected ground...")) if showMessages
            return true
          elsif [:POISONGAS,:CORROSIVEGAS,:SMOKESCREEN].include?(@id)
            @battle.pbDisplay(_INTL("But the infinite space swallowed up the gas...")) if showMessages
            return true
          elsif soundMove?(user)
            @battle.pbDisplay(_INTL("The infinite space absorbed the sound!")) if showMessages
            return true
          end
        when 38 # Dimensional Field
          if [:LIGHTSCREEN,:SYNTHESIS,:MORNINGSUN,:MOONLIGHT,:SPOTLIGHT].include?(@id)
            @battle.pbDisplay(_INTL("The dimension absorbed the light!")) if showMessages
            return true
          elsif @id == :GEOMANCY
            @battle.pbDisplay(_INTL("The dimension negated the constructive energy!")) if showMessages
            return true
          elsif [:BANEFULBUNKER,:CRAFTYSHIELD,:DETECT,:KINGSSHIELD,:MATBLOCK,:OBSTRUCT,
                :PROTECT,:QUICKGUARD,:SPIKYSHIELD,:WIDEGUARD].include?(@id)
            @battle.pbDisplay(_INTL("The dimension negated the protective energy!")) if showMessages
            return true
          end
        when 39 # Frozen Dimensional Field
          if [:MAGICROOM,:GRAVITY,:TRICKROOM,:WONDERROOM].include?(@id)
            @battle.pbDisplay(_INTL("The frozen dimensions remain unchanged.")) if showMessages
            return true
          elsif [:MEDITATE,:CALMMIND,:FOCUSENERGY].include?(@id)
            @battle.pbDisplay(_INTL("The imminent anger overwhelms any potential tranquility!")) if showMessages
            return true
          elsif [:HELPINGHAND,:HOLDHANDS,:PLAYNICE].include?(@id)
            @battle.pbDisplay(_INTL("The imminent anger overwhelms any potential friendship!")) if showMessages
            return true
          elsif @id == :GEOMANCY
            @battle.pbDisplay(_INTL("The dimension negated the constructive energy!")) if showMessages
            return true
          end
        when 41 # Corrupted Cave
          if [:SEISMICTOSS,:SKYDROP,:THUNDER,:FLYINGPRESS,:DRAGONASCENT].include?(@id)
            @battle.pbDisplay(_INTL("But the cave's ceiling was too low...")) if showMessages
            return true
          elsif @id == :ROTOTILLER
            @battle.pbDisplay(_INTL("But the corrosion prevented the move from working...")) if showMessages
            return true
          end
        when 43 # Sky Field
          if [:EARTHQUAKE,:MAGNITUDE,:BULLDOZE,:ROTOTILLER,:STICKYWEB,:DIG,:SPIKES,:TOXICSPIKES,
             :EARTHPOWER,:STOMPINGTANTRUM,:TECTONICRAGE,:STEAMROLLER,:STOMP,:BODYSLAM,
             :HEAVYSLAM,:CORKSCREWCRASH,:PULVERIZINGPANCAKE,:BODYPRESS,:CONTINENTALCRUSH].include?(@id)
            @battle.pbDisplay(_INTL("But the attack had no effect in the sky!")) if showMessages
            return true
          end
        when 44 # Indoors
          if @id == :DEFOG
            @battle.pbDisplay(_INTL("But there was no fog inside...")) if showMessages
            return true
          elsif @id == :TAILWIND
            @battle.pbDisplay(_INTL("But there was no passage for continuous airflow...")) if showMessages
            return true
          elsif @id == :SKYDROP
            @battle.pbDisplay(_INTL("But the ceiling was too low...")) if showMessages
            return true
          elsif @id == :GEOMANCY
            @battle.pbDisplay(_INTL("But nature thrives outside...")) if showMessages
            return true
          end
        when 46 # Subzero Field
          if user.hasActiveAbility?(:KLUTZ) && contactMove? && @battle.pbRandom(4) == 0
            @battle.pbDisplay(_INTL("{1} accidentally slipped and fell on the ice, preventing it from completing its move.",user.pbThis)) if showMessages
            return true
          end
        when 49 # Xeric Shrubland
          if @id == :SHEERCOLD
            @battle.pbDisplay(_INTL("But the hot desert nullified the attack!")) if showMessages
            return true
          end
        end
      end
      return false
    end
    
    # Field Move Fail 2
    def failsDueToFieldTarget?(user,target,showMessages=false)
      if !zMove?
        case $fefieldeffect
        when 3 # Misty Terrain
          if [:TORMENT,:TAUNT].include?(@id)
            @battle.pbDisplay(_INTL("But {1} remained calm...",target.pbThis(true))) if showMessages
            return true
          end
        when 8 # Swamp
          if target.grounded? && @id == :TARSHOT
            @battle.pbDisplay(_INTL("But {1} was already covered in mud...",target.pbThis(true))) if showMessages
            return true
          end
        when 9 # Rainbow Field
          if target.hasActiveAbility?(:WONDERSKIN) && statusMove? && !@battle.moldBreaker
            @battle.pbDisplay(_INTL("{1} avoided the attack with {2}",target.pbThis,target.abilityName)) if showMessages
            return true
          end
        when 20 # Ashen Beach
          if [:TORMENT,:TAUNT].include?(@id)
            @battle.pbDisplay(_INTL("But {1} remained calm...",target.pbThis(true))) if showMessages
            return true
          end
        when 21 # Water Surface
          if ([:SANDATTACK,:POLLENPUFF,:SCORCHINGSANDS,:DUSTSTORM].include?(@id) || 
             powderMove?) && target.grounded?
            @battle.pbDisplay(_INTL("But the water washed away the attack...")) if showMessages
            return true
          end
        when 25 # Crystal Cavern
          if target.hasActiveAbility?(:WONDERSKIN) && statusMove? && !@battle.moldBreaker
            @battle.pbDisplay(_INTL("{1} avoided the attack with {2}",target.pbThis,target.abilityName)) if showMessages
            return true
          end
        when 29 # Holy Field
          if target.hasActiveAbility?([:MAGICGUARD,:MAGICBOUNCE]) && (@calcTypes.include?(:DARK) ||
             @calcTypes.include?(:GHOST)) && !@battle.moldBreaker
            @battle.pbDisplay(_INTL("{1}'s {2} protects it from evil!",target.pbThis,target.abilityName)) if showMessages
            return true
          end
          if target.hasActiveAbility?(:WONDERGUARD) && statusMove? && !@battle.moldBreaker
            @battle.pbDisplay(_INTL("{1}'s {2} protects it from the attack!",target.pbThis,target.abilityName)) if showMessages
            return true
          end
        when 34 # Starlight Arena
          if target.hasActiveAbility?(:WONDERSKIN) && statusMove? && !@battle.moldBreaker
            @battle.pbDisplay(_INTL("{1} avoided the attack with {2}",target.pbThis,target.abilityName)) if showMessages
            return true
          end
        when 37 # Psychic Terrain
          if target.opposes?(user) && @battle.choices[user.index][4]>0   # Move priority saved from pbCalculatePriority
            @battle.pbDisplay(_INTL("{1} surrounds itself with the Psychic Terrain!",target.pbThis)) if showMessages
            return true
          elsif target.hasActiveAbility?([:OBLIVIOUS,:SIMPLE,:UNAWARE]) && @calcTypes.include?(:PSYCHIC) &&
                !@battle.moldBreaker
            @battle.pbDisplay(_INTL("{1}'s {2} renders it too unintelligent to succumb to Psychic moves...",target.pbThis,target.abilityName)) if showMessages
            return true
          end
        when 48 # Beach
          if [:TORMENT,:TAUNT].include?(@id)
            @battle.pbDisplay(_INTL("But {1} remained calm...",target.pbThis(true))) if showMessages
            return true
          end
        end
      end
      return false
    end
  
    #=============================================================================
    # Weaken the damage dealt (doesn't actually change a battler's HP)
    #=============================================================================
    def pbCheckDamageAbsorption(user,target)
      # Substitute will take the damage
      if target.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(user) &&
         (!user || user.index!=target.index)
        target.damageState.substitute = true
        return
      end
      # Disguise will take the damage
      if !@battle.moldBreaker && target.pokemon.getNumForms >= 1 && #target.isSpecies?(:MIMIKYU) &&
         target.form == 0 && target.hasActiveAbility?(:DISGUISE,false,true) && $fefieldeffect != 29
        target.damageState.disguise = true
        return
      end
      # Ice Face will take the damage
      if !@battle.moldBreaker && target.pokemon.getNumForms >= 1 && #target.isSpecies?(:EISCUE) &&
         target.form == 0 && target.hasActiveAbility?(:LIMBER,false,true) && physicalMove?
        target.damageState.iceface = true
        return
      end
    end
  
    def pbReduceDamage(user,target)
      damage = target.damageState.calcDamage
      # Substitute takes the damage
      if target.damageState.substitute
        damage = target.effects[PBEffects::Substitute] if damage>target.effects[PBEffects::Substitute]
        target.damageState.hpLost       = damage
        target.damageState.totalHPLost += damage
        return
      end
      # Damage converted to healing
      if !user.opposes?(target)
        if @function == "16F" # Pollen Puff
          target.pbRecoverHP(damage)
          @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
          return
        elsif target.hasActiveAbility?(:SPONGE) && ![12,49].include?($fefieldeffect)
          if target.canHeal?
            target.pbRecoverHP(damage)
            @battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",target.pbThis,target.abilityName))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} nullified the damage from the attack!",target.pbThis,target.abilityName))
          end
          return
        end
      end
      # Disguise takes the damage
      return if target.damageState.disguise
      # Ice Face takes the damage
      return if target.damageState.iceface
      # Target takes the damage
      if damage>=target.hp
        damage = target.hp
        randFocusBand = @battle.pbRandom(100)
        # Survive a lethal hit with 1 HP effects
        if nonLethal?(user,target)
          damage -= 1
        elsif target.effects[PBEffects::Endure]
          target.damageState.endured = true
          damage -= 1
        elsif damage==target.totalhp
          if !@battle.moldBreaker && (target.hasActiveAbility?(:STURDY) && ![13,21,26,43,46,48].include?($fefieldeffect) ||
             target.hasActiveAbility?(:INNERFOCUS) && $fefieldeffect == 45)
            target.damageState.sturdy = true
            damage -= 1
          elsif target.hasActiveItem?(:FOCUSSASH) && (target.hp==target.totalhp || 
                [17,20,45].include?($fefieldeffect) && target.hp >= target.totalhp*3/4)
            target.damageState.focusSash = true
            damage -= 1
          end
        elsif target.hasActiveItem?(:FOCUSBAND) && (randFocusBand < 10 || [17,20,45].include?($fefieldeffect) &&
              randFocusBand < 20)
          target.damageState.focusBand = true
          damage -= 1
        end
      end
      damage = 0 if damage<0
      target.damageState.hpLost       = damage
      target.damageState.totalHPLost += damage
    end
  
    #=============================================================================
    # Change the target's HP by the amount calculated above
    #=============================================================================
    def pbInflictHPDamage(target,user)
      if target.damageState.substitute
        target.effects[PBEffects::Substitute] -= target.damageState.hpLost
      else
        target.hp -= target.damageState.hpLost
      end
    end
  
    #=============================================================================
    # Animate the damage dealt, including lowering the HP
    #=============================================================================
    # Animate being damaged and losing HP (by a move)
    def pbAnimateHitAndHPLost(user,targets)
      # Animate allies first, then foes
      animArray = []
      for side in 0...2   # side here means "allies first, then foes"
        targets.each do |b|
          next if b.damageState.unaffected || b.damageState.hpLost==0
          next if (side==0 && b.opposes?(user)) || (side==1 && !b.opposes?(user))
          oldHP = b.hp+b.damageState.hpLost
          PBDebug.log("[Move damage] #{b.pbThis} lost #{b.damageState.hpLost} HP (#{oldHP}=>#{b.hp})")
          effectiveness = 0
          if Effectiveness.resistant?(b.damageState.typeMod);          effectiveness = 1
          elsif Effectiveness.super_duper_effective?(b.damageState.typeMod); effectiveness = 3
          elsif Effectiveness.super_effective?(b.damageState.typeMod); effectiveness = 2
          end
          animArray.push([b,oldHP,effectiveness])
        end
        if animArray.length>0
          @battle.scene.pbHitAndHPLossAnimation(animArray)
          animArray.clear
        end
      end
    end
  
    #=============================================================================
    # Messages upon being hit
    #=============================================================================
    def pbEffectivenessMessage(user,target,numTargets=1)
      return if target.damageState.disguise
      return if target.damageState.iceface
      if Effectiveness.super_effective?(target.damageState.typeMod)
        if numTargets>1
          @battle.pbDisplay(_INTL("It's super effective on {1}!",target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("It's super effective!"))
        end
      elsif Effectiveness.not_very_effective?(target.damageState.typeMod)
        if numTargets>1
          @battle.pbDisplay(_INTL("It's not very effective on {1}...",target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("It's not very effective..."))
        end
      end
    end
  
    def pbHitEffectivenessMessages(user,target,numTargets=1)
      return if target.damageState.disguise
      return if target.damageState.iceface
      if target.damageState.substitute
        @battle.pbDisplay(_INTL("The substitute took damage for {1}!",target.pbThis(true)))
      end
      if target.damageState.critical
        if numTargets>1
          @battle.pbDisplay(_INTL("A critical hit on {1}!",target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("A critical hit!"))
        end
       user.critical_hits += 1
      end
      # Effectiveness message, for moves with 1 hit
      if !multiHitMove? && user.effects[PBEffects::ParentalBond]==0 && user.effects[PBEffects::HitsTwice] == 0
        pbEffectivenessMessage(user,target,numTargets)
      end
      if target.damageState.substitute && target.effects[PBEffects::Substitute]==0
        target.effects[PBEffects::Substitute] = 0
        @battle.scene.pbUnSubstituteSprite(target,target.opposes?)
        @battle.pbDisplay(_INTL("{1}'s substitute faded!",target.pbThis))
      end
    end
  
    def pbEndureKOMessage(target)
      if target.damageState.disguise
        @battle.pbShowAbilitySplash(target)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("Its disguise served it as a decoy!"))
        else
          @battle.pbDisplay(_INTL("{1}'s disguise served it as a decoy!",target.pbThis))
        end
        @battle.pbHideAbilitySplash(target)
        if ![40,45].include?($fefieldeffect) || @battle.pbRandom(2) == 0
          if target.opposes?
            @battle.pbCommonAnimation("DisguiseBust1Opp",target)
          else
            @battle.pbCommonAnimation("DisguiseBust1",target)
          end
          target.pbChangeForm(1,_INTL("{1}'s disguise was busted!",target.pbThis))
          target.pbReduceHP(target.totalhp/8)
        else
          @battle.pbDisplay(_INTL("{1}'s disguise was damaged!",target.pbThis))
        end
      elsif target.damageState.iceface
        @battle.pbShowAbilitySplash(target)
        target.pbChangeForm(1,_INTL("{1} transformed!",target.pbThis))
        @battle.pbHideAbilitySplash(target)
      elsif target.damageState.endured
        @battle.pbDisplay(_INTL("{1} endured the hit!",target.pbThis))
        if $fefieldeffect == 20
          target.pbRecoverHP(target.totalhp/2)>0
        end
      elsif target.damageState.sturdy
        @battle.pbShowAbilitySplash(target)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} endured the hit!",target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} hung on with {2}!",target.pbThis,target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
        if $fefieldeffect == 45
          target.pbRaiseStatStage(:SPEED,1,target)
        end
      elsif target.damageState.focusSash
        @battle.pbCommonAnimation("UseItem",target)
        @battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!",target.pbThis))
        target.pbConsumeItem
      elsif target.damageState.focusBand
        @battle.pbCommonAnimation("UseItem",target)
        @battle.pbDisplay(_INTL("{1} hung on using its Focus Band!",target.pbThis))
      end
    end
  
    # Used by Counter/Mirror Coat/Metal Burst/Revenge/Focus Punch/Bide/Assurance.
    def pbRecordDamageLost(user,target)
      damage = target.damageState.hpLost
      target.damage_done += damage
      # NOTE: In Gen 3 where a move's category depends on its type, Hidden Power
      #       is for some reason countered by Counter rather than Mirror Coat,
      #       regardless of its calculated type. Hence the following two lines of
      #       code.
      moveType = nil
      moveType = :NORMAL if @function=="090"   # Hidden Power
      if physicalMove?(moveType)
        target.effects[PBEffects::Counter]       = damage
        target.effects[PBEffects::CounterTarget] = user.index
      elsif specialMove?(moveType)
        target.effects[PBEffects::MirrorCoat]       = damage
        target.effects[PBEffects::MirrorCoatTarget] = user.index
      end
      if target.effects[PBEffects::Bide]>0
        target.effects[PBEffects::BideDamage] += damage
        target.effects[PBEffects::BideTarget] = user.index
      end
      target.damageState.fainted = true if target.fainted?
      target.lastHPLost = damage             # For Focus Punch
      target.tookDamage = true if damage>0   # For Assurance
      target.lastAttacker.push(user.index)   # For Revenge
      if target.opposes?(user)
        target.lastHPLostFromFoe = damage              # For Metal Burst
        target.lastFoeAttacker.push(user.index)        # For Metal Burst
      end
    end
  end
  