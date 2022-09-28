#===============================================================================
# Superclass that handles moves using a non-existent function code.
# Damaging moves just do damage with no additional effect.
# Status moves always fail.
#===============================================================================
class PokeBattle_UnimplementedMove < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if statusMove?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  end
  
  
  
  #===============================================================================
  # Pseudomove for confusion damage.
  #===============================================================================
  class PokeBattle_Confusion < PokeBattle_Move
    def initialize(battle,move)
      @battle     = battle
      @realMove   = move
      @id         = 0
      @name       = ""
      @function   = "000"
      @baseDamage = 40
      @type       = nil
      @category   = 0
      @accuracy   = 100
      @pp         = -1
      @target     = 0
      @priority   = 0
      @flags      = ""
      @addlEffect = 0
      @calcTypes  = nil
      @powerBoost = 1
      @snatched   = false
      @types      = [@type]
    end
  
    def physicalMove?(thisType=nil);    return true;  end
    def specialMove?(thisType=nil);     return false; end
    def pbCritialOverride(user,target); return -1;    end
  end
  
  
  
  #===============================================================================
  # Pseudomove for AI to determine damage if no damaging revealed STAB move of
  # this type.
  #===============================================================================
  class PokeBattle_AI_Pseudomove < PokeBattle_Move
    def initialize(battle,user,type)
      @battle     = battle
      @realMove   = nil
      @id         = :PSEUDOMOVE
      @name       = "AI Pseudomove"
      @function   = "000"
      @baseDamage = user.level >= 40 ? 80 : [(4*user.level + 80)/3,40].max
      @type       = type
      @category   = (user.pbAttack(false) > user.pbSpAtk(false)) ? 0 : 1 # Whichever attacking stat is higher
      @accuracy   = 100
      @pp         = 0 # Indefinite use
      @target     = :NearOther
      @priority   = 0
      @flags      = "bef"
      @addlEffect = 0
      @calcTypes  = nil
      @powerBoost = 1
      @snatched   = false
      @types      = [@type]
    end
  end
  
  
  
  #===============================================================================
  # Implements the move Struggle.
  # For cases where the real move named Struggle is not defined.
  #===============================================================================
  class PokeBattle_Struggle < PokeBattle_Move
    def initialize(battle,move)
      @battle     = battle
      @realMove   = nil                     # Not associated with a move
      @id         = (move) ? move.id : :STRUGGLE
      @name       = (move) ? move.name : _INTL("Struggle")
      @function   = "002"
      @baseDamage = 50
      @type       = nil
      @category   = 0
      @accuracy   = 0
      @pp         = -1
      @target     = 0
      @priority   = 0
      @flags      = ""
      @addlEffect = 0
      @calcTypes  = nil
      @powerBoost = 1
      @snatched   = false
      @types      = [@type]
    end
  
    def physicalMove?(thisType=nil); return true;  end
    def specialMove?(thisType=nil);  return false; end
  
    def pbEffectAfterAllHits(user,target)
      return if target.damageState.unaffected
      user.pbReduceHP((user.totalhp/4.0).round,false,true,true,true)
      @battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
      if !user.fainted?
        user.pokemon.recoil_damage += amt
      end
      user.pbItemHPHealCheck
    end
  end
  
  
  
  #===============================================================================
  # Generic status problem-inflicting classes.
  #===============================================================================
  class PokeBattle_SleepMove < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      return false if damagingMove?
      return !target.pbCanSleep?(user,true,self)
    end
  
    def pbEffectAgainstTarget(user,target)
      return if damagingMove?
      target.pbSleep
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      target.pbSleep if target.pbCanSleep?(user,false,self)
    end
  end
  
  
  
  class PokeBattle_PoisonMove < PokeBattle_Move
    def initialize(battle,move)
      super
      @toxic = false
    end
  
    def pbFailsAgainstTarget?(user,target)
      return false if damagingMove?
      return !target.pbCanPoison?(user,true,self)
    end
  
    def pbEffectAgainstTarget(user,target)
      return if damagingMove?
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      if $fefieldeffect == 19
        target.pbCheckAndInflictRandomStatus(user,true,self)
      elsif $fefieldeffect == 11
        target.pbPoison(user,nil,true) if target.pbCanPoison?(user,false,self)
      else
        target.pbPoison(user,nil,@toxic) if target.pbCanPoison?(user,false,self)
      end
    end
  end
  
  
  
  class PokeBattle_ParalysisMove < PokeBattle_Move
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
  
  
  
  class PokeBattle_BurnMove < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      return false if damagingMove?
      return !target.pbCanBurn?(user,true,self)
    end
  
    def pbEffectAgainstTarget(user,target)
      return if damagingMove?
      target.pbBurn(user)
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      target.pbBurn(user) if target.pbCanBurn?(user,false,self)
    end
  end
  
  
  
  class PokeBattle_FreezeMove < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      return false if damagingMove?
      return !target.pbCanFreeze?(user,true,self)
    end
  
    def pbEffectAgainstTarget(user,target)
      return if damagingMove?
      target.pbFreeze
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      target.pbFreeze if target.pbCanFreeze?(user,false,self)
    end
  end
  
  
  
  #===============================================================================
  # Other problem-causing classes.
  #===============================================================================
  class PokeBattle_FlinchMove < PokeBattle_Move
    def flinchingMove?; return true; end
  
    def pbEffectAgainstTarget(user,target)
      return if damagingMove?
      target.pbFlinch(user)
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      target.pbFlinch(user)
    end
  end
  
  
  
  class PokeBattle_ConfuseMove < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      return false if damagingMove?
      return !target.pbCanConfuse?(user,true,self)
    end
  
    def pbEffectAgainstTarget(user,target)
      return if damagingMove?
      target.pbConfuse
      if $fefieldeffect == 31 && @id == :SWEETKISS && target.asleep?
        target.pbCureStatus
      end
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      return if !target.pbCanConfuse?(user,false,self)
      target.pbConfuse
    end
  end
  
  
  
  #===============================================================================
  # Generic user's stat increase/decrease classes.
  #===============================================================================
  class PokeBattle_StatUpMove < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      return false if damagingMove?
      failed = true
      for i in 0...getStatUp.length/2
        next if !user.pbCanRaiseStatStage?(getStatUp[i*2],user,self)
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
      for i in 0...getStatUp.length/2
        next if !user.pbCanRaiseStatStage?(getStatUp[i*2],user,self)
        if user.pbRaiseStatStage(getStatUp[i*2],getStatUp[i*2+1],user,showAnim)
          showAnim = false
        end
      end
    end
  
    def pbAdditionalEffect(user,target)
      showAnim = true
      for i in 0...getStatUp.length/2
        next if !user.pbCanRaiseStatStage?(getStatUp[i*2],user,self)
        if user.pbRaiseStatStage(getStatUp[i*2],getStatUp[i*2+1],user,showAnim)
          showAnim = false
        end
      end
    end
  end
  
  class PokeBattle_StatDownMove < PokeBattle_Move
    def pbEffectWhenDealingDamage(user,target)
      return if @battle.pbAllFainted?(target.idxOwnSide)
      showAnim = true
      for i in 0...getStatDown.length/2
        next if !user.pbCanLowerStatStage?(getStatDown[i*2],user,self)
        if user.pbLowerStatStage(getStatDown[i*2],getStatDown[i*2+1],user,showAnim)
          showAnim = false
        end
      end
    end
  end
  
  
  
  #===============================================================================
  # Generic target's stat increase/decrease classes.
  #===============================================================================
  class PokeBattle_TargetStatUpMove < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      return false if damagingMove?
      failed = true
      for i in 0...getStatUp.length/2
        next if !target.pbCanRaiseStatStage?(getStatUp[i*2],user,self)
        failed = false
        break
      end
      if failed
        # NOTE: It's a bit of a faff to make sure the appropriate failure message
        #       is shown here, I know.
        canRaise = false
        if target.hasActiveAbility?(:CONTRARY) && !@battle.moldBreaker
          for i in 0...getStatUp.length/2
            next if target.statStageAtMin?(getStatUp[i*2])
            canRaise = true
            break
          end
          @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",target.pbThis)) if !canRaise
        else
          for i in 0...getStatUp.length/2
            next if target.statStageAtMax?(getStatUp[i*2])
            canRaise = true
            break
          end
          @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",target.pbThis)) if !canRaise
        end
        if canRaise
          target.pbCanRaiseStatStage?(getStatUp[0],user,self,true)
        end
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      return if damagingMove?
      showAnim = true
      for i in 0...getStatUp.length/2
        next if !target.pbCanRaiseStatStage?(getStatUp[i*2],user,self)
        if target.pbRaiseStatStage(getStatUp[i*2],getStatUp[i*2+1],user,showAnim)
          showAnim = false
        end
      end
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      showAnim = true
      for i in 0...getStatUp.length/2
        next if !target.pbCanLowerStatStage?(getStatUp[i*2],user,self)
        if target.pbRaiseStatStage(getStatUp[i*2],getStatUp[i*2+1],user,showAnim)
          showAnim = false
        end
      end
    end
  end
  
  class PokeBattle_TargetStatDownMove < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      return false if damagingMove?
      failed = true
      for i in 0...getStatDown.length/2
        next if !target.pbCanLowerStatStage?(getStatDown[i*2],user,self)
        failed = false
        break
      end
      if failed
        # NOTE: It's a bit of a faff to make sure the appropriate failure message
        #       is shown here, I know.
        canLower = false
        if target.hasActiveAbility?(:CONTRARY) && !@battle.moldBreaker
          for i in 0...getStatDown.length/2
            next if target.statStageAtMax?(getStatDown[i*2])
            canLower = true
            break
          end
          @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",target.pbThis)) if !canLower
        else
          for i in 0...getStatDown.length/2
            next if target.statStageAtMin?(getStatDown[i*2])
            canLower = true
            break
          end
          @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",target.pbThis)) if !canLower
        end
        if canLower
          target.pbCanLowerStatStage?(getStatDown[0],user,self,true)
        end
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      return if damagingMove?
      showAnim = true
      for i in 0...getStatDown.length/2
        next if !target.pbCanLowerStatStage?(getStatDown[i*2],user,self)
        if target.pbLowerStatStage(getStatDown[i*2],getStatDown[i*2+1],user,showAnim)
          showAnim = false
        end
      end
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      showAnim = true
      for i in 0...getStatDown.length/2
        next if !target.pbCanLowerStatStage?(getStatDown[i*2],user,self)
        if target.pbLowerStatStage(getStatDown[i*2],getStatDown[i*2+1],user,showAnim)
          showAnim = false
        end
      end
    end
  end
  
  
  
  #===============================================================================
  # Fixed damage-inflicting move.
  #===============================================================================
  class PokeBattle_FixedDamageMove < PokeBattle_Move
    def pbFixedDamage(user,target); return 1; end
  
    def pbCalcDamage(user,target,numTargets=1)
      target.damageState.critical   = false
      target.damageState.calcDamage = pbFixedDamage(user,target)
      target.damageState.calcDamage = 1 if target.damageState.calcDamage<1
      target.damageState.typeMod    = 8 if target.damageState.typeMod > 0
    end
  end
  
  
  
  #===============================================================================
  # Two turn move.
  #===============================================================================
  class PokeBattle_TwoTurnMove < PokeBattle_Move
    def chargingTurnMove?; return true; end
  
    # user.effects[PBEffects::TwoTurnAttack] is set to the move's ID if this
    # method returns true, or nil if false.
    # Non-nil means the charging turn. nil means the attacking turn.
    def pbIsChargingTurn?(user)
      @powerHerb = false
      @chargingTurn = false   # Assume damaging turn by default
      @damagingTurn = true
      # 0 at start of charging turn, move's ID at start of damaging turn
      if !user.effects[PBEffects::TwoTurnAttack]
        @powerHerb = user.hasActiveItem?(:POWERHERB)
        @chargingTurn = true
        @damagingTurn = @powerHerb || user.hasActiveAbility?(:ATTENTIVE) && $fefieldeffect != 37
      end
      return !@damagingTurn   # Deliberately not "return @chargingTurn"
    end
  
    def pbDamagingMove?   # Stops damage being dealt in the first (charging) turn
      return false if !@damagingTurn
      return super
    end
  
    def pbAccuracyCheck(user,target)
      return true if !@damagingTurn
      return super
    end
  
    def pbInitialEffect(user,targets,hitNum)
      super
      pbChargingTurnMessage(user,targets) if @chargingTurn
      if @chargingTurn && @damagingTurn   # Move only takes one turn to use
        pbShowAnimation(@id,user,targets,1)   # Charging anim
        targets.each { |b| pbChargingTurnEffect(user,b) }
        if @powerHerb
          # Moves that would make the user semi-invulnerable will hide the user
          # after the charging animation, so the "UseItem" animation shouldn't show
          # for it
          if !["0C9","0CA","0CB","0CC","0CD","0CE","14D"].include?(@function)
            @battle.pbCommonAnimation("UseItem",user)
          end
          @battle.pbDisplay(_INTL("{1} became fully charged due to its {2}!",user.pbThis,user.itemName))
          user.pbConsumeItem
        end
      end
      pbAttackingTurnMessage(user,targets) if @damagingTurn
    end
  
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} began charging up!",user.pbThis))
    end
  
    def pbAttackingTurnMessage(user,targets)
    end
  
    def pbChargingTurnEffect(user,target)
      # Skull Bash/Sky Drop are the only two-turn moves with an effect here, and
      # the latter just records the target is being Sky Dropped
    end
  
    def pbAttackingTurnEffect(user,target)
      user.effects[PBEffects::TwoTurnAttack] = nil
    end
  
    def pbEffectAgainstTarget(user,target)
      if @damagingTurn;    pbAttackingTurnEffect(user,target)
      elsif @chargingTurn; pbChargingTurnEffect(user,target)
      end
    end
  end
  
  
  
  #===============================================================================
  # Healing move.
  #===============================================================================
  class PokeBattle_HealingMove < PokeBattle_Move
    def healingMove?;       return true; end
    def pbHealAmount(user); return 1;    end
  
    def pbMoveFailed?(user,targets)
      if user.hp==user.totalhp
        @battle.pbDisplay(_INTL("{1}'s HP is full!",user.pbThis))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      amt = pbHealAmount(user)
      user.pbRecoverHP(amt)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # Recoil move.
  #===============================================================================
  class PokeBattle_RecoilMove < PokeBattle_Move
    def recoilMove?;                 return true; end
    def pbRecoilDamage(user,target); return 1;    end
  
    def pbEffectAfterAllHits(user,target)
      return if target.damageState.unaffected
      return if !user.takesIndirectDamage?
      return if user.hasActiveAbility?(:ROCKHEAD)
      amt = pbRecoilDamage(user,target)
      amt = 1 if amt<1
      user.pbReduceHP(amt,false)
      @battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
      if !user.fainted?
        user.pokemon.recoil_damage += amt
      end
      user.pbItemHPHealCheck
    end
  end
  
  
  
  #===============================================================================
  # Protect move.
  #===============================================================================
  class PokeBattle_ProtectMove < PokeBattle_Move
    def initialize(battle,move)
      super
      @sidedEffect = false
    end
  
    def pbChangeUsageCounters(user,specialUsage)
      oldVal = user.effects[PBEffects::ProtectRate]
      super
      user.effects[PBEffects::ProtectRate] = oldVal
    end
  
    def pbMoveFailed?(user,targets)
      if @sidedEffect
        if user.pbOwnSide.effects[@effect]
          user.effects[PBEffects::ProtectRate] = 1
          @battle.pbDisplay(_INTL("But it failed!"))
          return true
        end
      elsif user.effects[@effect]
        user.effects[PBEffects::ProtectRate] = 1
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if (!@sidedEffect || Settings::MECHANICS_GENERATION <= 5) &&
         user.effects[PBEffects::ProtectRate] > 1 && @battle.pbRandom(user.effects[PBEffects::ProtectRate]) != 0
        user.effects[PBEffects::ProtectRate] = 1
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if pbMoveFailedLastInRound?(user)
        user.effects[PBEffects::ProtectRate] = 1
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      if @sidedEffect
        user.pbOwnSide.effects[@effect] = true
      else
        user.effects[@effect] = true
      end
      user.effects[PBEffects::ProtectRate] *= (Settings::MECHANICS_GENERATION >= 6) ? 3 : 2
      pbProtectMessage(user)
    end
  
    def pbProtectMessage(user)
      if @sidedEffect
        @battle.pbDisplay(_INTL("{1} protected {2}!",@name,user.pbTeam(true)))
      else
        @battle.pbDisplay(_INTL("{1} protected itself!",user.pbThis))
      end
    end
  end
  
  
  
  #===============================================================================
  # Weather-inducing move.
  #===============================================================================
  class PokeBattle_WeatherMove < PokeBattle_Move
    def initialize(battle,move)
      super
      @weatherType = :None
    end
  
    def pbMoveFailed?(user,targets)
      case @battle.field.weather
      when :HarshSun
        @battle.pbDisplay(_INTL("The extremely harsh sunlight was not lessened at all!"))
        return true
      when :HeavyRain
        @battle.pbDisplay(_INTL("There is no relief from this heavy rain!"))
        return true
      when :StrongWinds
        @battle.pbDisplay(_INTL("The mysterious air current blows on regardless!"))
        return true
      when @weatherType
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      case $fefieldeffect
      when 22 # Underwater
        @battle.pbDisplay(_INTL("But the weather remained on the surface!"))
        return true
      when 35 # New World
        @battle.pbDisplay(_INTL("But the weather vanished into space!"))
        return true
      when 44 # Indoors
        @battle.pbDisplay(_INTL("But the weather remained outside!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      @battle.pbStartWeather(user,@weatherType,true,false)
    end
  end
  
  
  
  #===============================================================================
  # Pledge move.
  #===============================================================================
  class PokeBattle_PledgeMove < PokeBattle_Move
    def pbOnStartUse(user,targets)
      @pledgeSetup = false; @pledgeCombo = false; @pledgeOtherUser = nil
      @comboEffect = nil; @overrideType = nil; @overrideAnim = nil
      # Check whether this is the use of a combo move
      @combos.each do |i|
        next if i[0]!=user.effects[PBEffects::FirstPledge]
        @battle.pbDisplay(_INTL("The two moves have become one! It's a combined move!"))
        @pledgeCombo = true
        @comboEffect = i[1]; @overrideType = i[2]; @overrideAnim = i[3]
        @overrideType = nil if !GameData::Type.exists?(@overrideType)
        break
      end
      return if @pledgeCombo
      # Check whether this is the setup of a combo move
      user.eachAlly do |b|
        next if @battle.choices[b.index][0]!=:UseMove || b.movedThisRound?
        move = @battle.choices[b.index][2]
        next if !move
        @combos.each do |i|
          next if i[0]!=move.function
          @pledgeSetup = true
          @pledgeOtherUser = b
          break
        end
        break if @pledgeSetup
      end
    end
  
    def pbDamagingMove?
      return false if @pledgeSetup
      return super
    end
  
    def pbBaseTypes(user)
      return [@overrideType] if @overrideType!=nil
      return super
    end
  
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 2 if @pledgeCombo
      return baseDmg
    end
  
    def pbEffectGeneral(user)
      user.effects[PBEffects::FirstPledge] = 0
      return if !@pledgeSetup
      @battle.pbDisplay(_INTL("{1} is waiting for {2}'s move...",
         user.pbThis,@pledgeOtherUser.pbThis(true)))
      @pledgeOtherUser.effects[PBEffects::FirstPledge] = @function
      @pledgeOtherUser.effects[PBEffects::MoveNext]    = true
      user.lastMoveFailed = true   # Treated as a failure for Stomping Tantrum
    end
  
    def pbEffectAfterAllHits(user,target)
      return if !@pledgeCombo
      msg = nil; animName = nil
      case @comboEffect
      when :SeaOfFire   # Grass + Fire
        animName = (user.opposes?) ? "SeaOfFireOpp" : "SeaOfFire"
      when :Rainbow   # Fire + Water
        animName = (user.opposes?) ? "RainbowOpp" : "Rainbow"
      when :Swamp   # Water + Grass
        animName = (user.opposes?) ? "SwampOpp" : "Swamp"
      end
      @battle.pbCommonAnimation(animName) if animName
      case @comboEffect
      when :SeaOfFire   # Grass + Fire
        @battle.changeField(16,"A blazing volcano burst up from the ground!",5,user.hasTerrainExtender?,true)
      when :Rainbow   # Fire + Water
        @battle.changeField(9,"A shimmering rainbow revealed itself in the sky!",5,user.hasTerrainExtender?,true)
      when :Swamp   # Water + Grass
        @battle.changeField(8,"A smelly swamp enveloped the field!",5,user.hasTerrainExtender?,true)
      end
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      return if @pledgeSetup   # No animation for setting up
      id = @overrideAnim if @overrideAnim
      return super
    end
  end
  