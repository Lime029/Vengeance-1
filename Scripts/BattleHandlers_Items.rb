#===============================================================================
# SpeedCalcItem handlers
#===============================================================================

BattleHandlers::SpeedCalcItem.add(:CHOICESCARF,
    proc { |item,battler,mult|
      next mult*1.5
    }
  )
  
  BattleHandlers::SpeedCalcItem.add(:MACHOBRACE,
    proc { |item,battler,mult|
      next mult/2
    }
  )
  
  BattleHandlers::SpeedCalcItem.copy(:MACHOBRACE,:POWERANKLET,:POWERBAND,
                                                 :POWERBELT,:POWERBRACER,
                                                 :POWERLENS,:POWERWEIGHT)
  
  BattleHandlers::SpeedCalcItem.add(:QUICKPOWDER,
    proc { |item,battler,mult|
      next mult*1.5 if battler.isSpecies?(:DITTO) && !([21,26].include?($fefieldeffect) &&
                       battler.grounded?) && $fefieldeffect != 22
    }
  )
  
  BattleHandlers::SpeedCalcItem.add(:IRONBALL,
    proc { |item,battler,mult|
      next mult/2
    }
  )
  
  #===============================================================================
  # WeightCalcItem handlers
  #===============================================================================
  
  BattleHandlers::WeightCalcItem.add(:FLOATSTONE,
    proc { |item,battler,w|
      next [w/2,1].max
    }
  )
  
  #===============================================================================
  # HPHealItem handlers
  #===============================================================================
  
  BattleHandlers::HPHealItem.add(:AGUAVBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleConfusionBerry(battler,battle,item,forced,4,
         _INTL("For {1}, the {2} was too bitter!",battler.pbThis(true),GameData::Item.get(item).name))
    }
  )
  
  BattleHandlers::HPHealItem.add(:APICOTBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,:SPECIAL_DEFENSE)
    }
  )
  
  BattleHandlers::HPHealItem.add(:BERRYJUICE,
    proc { |item,battler,battle,forced|
      next false if !battler.canHeal?
      next false if !forced && battler.hp>battler.totalhp/2
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}") if forced
      battle.pbCommonAnimation("UseItem",battler) if !forced
      battler.pbRecoverHP(20)
      if forced
        battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} restored its health using its {2}!",battler.pbThis,itemName))
      end
      next true
    }
  )
  
  BattleHandlers::HPHealItem.copy(:BERRYJUICE,:BERRYJUICE1)
  
  BattleHandlers::HPHealItem.add(:FIGYBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleConfusionBerry(battler,battle,item,forced,0,
         _INTL("For {1}, the {2} was too spicy!",battler.pbThis(true),GameData::Item.get(item).name))
    }
  )
  
  BattleHandlers::HPHealItem.add(:GANLONBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,:DEFENSE)
    }
  )
  
  BattleHandlers::HPHealItem.add(:IAPAPABERRY,
    proc { |item,battler,battle,forced|
      next pbBattleConfusionBerry(battler,battle,item,forced,1,
         _INTL("For {1}, the {2} was too sour!",battler.pbThis(true),GameData::Item.get(item).name))
    }
  )
  
  BattleHandlers::HPHealItem.add(:LANSATBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumePinchBerry?
      next false if battler.effects[PBEffects::FocusEnergy]>=2
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      battler.effects[PBEffects::FocusEnergy] = 2
      itemName = GameData::Item.get(item).name
      if forced
        battle.pbDisplay(_INTL("{1} got pumped from the {2}!",battler.pbThis,itemName))
      else
        battle.pbDisplay(_INTL("{1} used its {2} to get pumped!",battler.pbThis,itemName))
      end
      next true
    }
  )
  
  BattleHandlers::HPHealItem.add(:LIECHIBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,:ATTACK)
    }
  )
  
  BattleHandlers::HPHealItem.add(:MAGOBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleConfusionBerry(battler,battle,item,forced,2,
         _INTL("For {1}, the {2} was too sweet!",battler.pbThis(true),GameData::Item.get(item).name))
    }
  )
  
  BattleHandlers::HPHealItem.add(:MICLEBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumePinchBerry?
      next false if !battler.effects[PBEffects::MicleBerry]
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      battler.effects[PBEffects::MicleBerry] = true
      itemName = GameData::Item.get(item).name
      if forced
        PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
        battle.pbDisplay(_INTL("{1} boosted the accuracy of its next move!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} boosted the accuracy of its next move using its {2}!",
           battler.pbThis,itemName))
      end
      next true
    }
  )
  
  BattleHandlers::HPHealItem.add(:ORANBERRY,
    proc { |item,battler,battle,forced|
      next false if !battler.canHeal?
      next false if !forced && !battler.canConsumePinchBerry?(false)
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      if battler.hasActiveAbility?(:RIPEN) && ![4,10,11,12,38,39,41,46].include?($fefieldeffect)
        if $fefieldeffect == 33 && $fecounter == 4
          battler.pbRecoverHP(40)
        elsif [2,15,47].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
          battler.pbRecoverHP(30)
        else
          battler.pbRecoverHP(20)
        end
      elsif battler.hasActiveAbility?(:GLUTTONY) && ([15,47].include?($fefieldeffect) || 
            $fefieldeffect == 33 && $fecounter >= 3)
        battler.pbRecoverHP(20)
      else
        battler.pbRecoverHP(10)
      end
      itemName = GameData::Item.get(item).name
      if forced
        PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
        battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",battler.pbThis,itemName))
      end
      next true
    }
  )
  
  BattleHandlers::HPHealItem.copy(:ORANBERRY,:ORANBERRY1)
  
  BattleHandlers::HPHealItem.add(:PETAYABERRY,
    proc { |item,battler,battle,forced|
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,:SPECIAL_ATTACK)
    }
  )
  
  BattleHandlers::HPHealItem.add(:SALACBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,:SPEED)
    }
  )
  
  BattleHandlers::HPHealItem.add(:SITRUSBERRY,
    proc { |item,battler,battle,forced|
      next false if !battler.canHeal?
      next false if !forced && !battler.canConsumePinchBerry?(false)
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      if battler.hasActiveAbility?(:RIPEN) && ![4,10,11,12,38,39,41,46].include?($fefieldeffect)
        if $fefieldeffect == 33 && $fecounter == 4
          battler.pbRecoverHP(battler.totalhp)
        elsif [2,15,47].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
          battler.pbRecoverHP(battler.totalhp*3/4)
        else
          battler.pbRecoverHP(battler.totalhp/2)
        end
      elsif battler.hasActiveAbility?(:GLUTTONY) && ([15,47].include?($fefieldeffect) || 
            $fefieldeffect == 33 && $fecounter >= 3)
        battler.pbRecoverHP(battler.totalhp/2)
      else
        battler.pbRecoverHP(battler.totalhp/4)
      end
      itemName = GameData::Item.get(item).name
      if forced
        PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
        battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} restored its health using its {2}!",battler.pbThis,itemName))
      end
      next true
    }
  )
  
  BattleHandlers::HPHealItem.copy(:SITRUSBERRY,:SITRUSBERRY1)
  
  BattleHandlers::HPHealItem.add(:STARFBERRY,
    proc { |item,battler,battle,forced|
      stats = []
      GameData::Stat.each_main_battle { |s| stats.push(s.id) if battler.pbCanRaiseStatStage?(s.id, battler) }
      next false if stats.length==0
      stat = stats[battle.pbRandom(stats.length)]
      next pbBattleStatIncreasingBerry(battler,battle,item,forced,stat,2)
    }
  )
  
  BattleHandlers::HPHealItem.add(:WIKIBERRY,
    proc { |item,battler,battle,forced|
      next pbBattleConfusionBerry(battler,battle,item,forced,3,
         _INTL("For {1}, the {2} was too dry!",battler.pbThis(true),GameData::Item.get(item).name))
    }
  )
  
  #===============================================================================
  # StatusCureItem handlers
  #===============================================================================
  
  BattleHandlers::StatusCureItem.add(:ASPEARBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      next false if battler.status != :FROZEN
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      battler.pbCureStatus(forced)
      battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,itemName)) if !forced
      next true
    }
  )
  
  BattleHandlers::StatusCureItem.copy(:ASPEARBERRY,:ASPEARBERRY1)
  
  BattleHandlers::StatusCureItem.add(:CHERIBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      next false if battler.status != :PARALYSIS
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      battler.pbCureStatus(forced)
      battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,itemName)) if !forced
      next true
    }
  )
  
  BattleHandlers::StatusCureItem.copy(:CHERIBERRY,:CHERIBERRY1)
  
  BattleHandlers::StatusCureItem.add(:CHESTOBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      next false if battler.status != :SLEEP
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      battler.pbCureStatus(forced)
      battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,itemName)) if !forced
      next true
    }
  )
  
  BattleHandlers::StatusCureItem.copy(:CHESTOBERRY,:CHESTOBERRY1)
  
  BattleHandlers::StatusCureItem.add(:LUMBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      next false if battler.status == :NONE &&
                    battler.effects[PBEffects::Confusion]==0
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      oldStatus = battler.status
      oldConfusion = (battler.effects[PBEffects::Confusion]>0)
      battler.pbCureStatus(forced)
      battler.pbCureConfusion
      if forced
        battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis)) if oldConfusion
      else
        case oldStatus
        when :SLEEP
          battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,itemName))
        when :POISON
          battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!",battler.pbThis,itemName))
        when :BURN
          battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,itemName))
        when :PARALYSIS
          battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,itemName))
        when :FROZEN
          battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,itemName))
        end
        if oldConfusion
          battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",battler.pbThis,itemName))
        end
      end
      next true
    }
  )
  
  BattleHandlers::StatusCureItem.copy(:LUMBERRY,:LUMBERRY1)
  
  BattleHandlers::StatusCureItem.add(:MENTALHERB,
    proc { |item,battler,battle,forced|
      next false if battler.effects[PBEffects::Attract]==-1 &&
                    battler.effects[PBEffects::Taunt]==0 &&
                    battler.effects[PBEffects::Encore]==0 &&
                    !battler.effects[PBEffects::Torment] &&
                    battler.effects[PBEffects::Disable]==0 &&
                    battler.effects[PBEffects::HealBlock]==0
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
      battle.pbCommonAnimation("UseItem",battler) if !forced
      if battler.effects[PBEffects::Attract]>=0
        if forced
          battle.pbDisplay(_INTL("{1} got over its infatuation.",battler.pbThis))
        else
          battle.pbDisplay(_INTL("{1} cured its infatuation status using its {2}!",
             battler.pbThis,itemName))
        end
        battler.pbCureAttract
      end
      battle.pbDisplay(_INTL("{1}'s taunt wore off!",battler.pbThis)) if battler.effects[PBEffects::Taunt]>0
      battler.effects[PBEffects::Taunt]      = 0
      battle.pbDisplay(_INTL("{1}'s encore ended!",battler.pbThis)) if battler.effects[PBEffects::Encore]>0
      battler.effects[PBEffects::Encore]     = 0
      battler.effects[PBEffects::EncoreMove] = nil
      battle.pbDisplay(_INTL("{1}'s torment wore off!",battler.pbThis)) if battler.effects[PBEffects::Torment]
      battler.effects[PBEffects::Torment]    = false
      battle.pbDisplay(_INTL("{1} is no longer disabled!",battler.pbThis)) if battler.effects[PBEffects::Disable]>0
      battler.effects[PBEffects::Disable]    = 0
      battle.pbDisplay(_INTL("{1}'s Heal Block wore off!",battler.pbThis)) if battler.effects[PBEffects::HealBlock]>0
      battler.effects[PBEffects::HealBlock]  = 0
      next true
    }
  )
  
  BattleHandlers::StatusCureItem.add(:PECHABERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      next false if battler.status != :POISON
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      battler.pbCureStatus(forced)
      battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!",battler.pbThis,itemName)) if !forced
      next true
    }
  )
  
  BattleHandlers::StatusCureItem.copy(:PECHABERRY,:PECHABERRY1)
  
  BattleHandlers::StatusCureItem.add(:PERSIMBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      next false if battler.effects[PBEffects::Confusion]==0
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      battler.pbCureConfusion
      if forced
        battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",battler.pbThis,
           itemName))
      end
      next true
    }
  )
  
  BattleHandlers::StatusCureItem.copy(:PERSIMBERRY,:PERSIMBERRY1)
  
  BattleHandlers::StatusCureItem.add(:RAWSTBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      next false if battler.status != :BURN
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      battler.pbCureStatus(forced)
      battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,itemName)) if !forced
      next true
    }
  )
  
  BattleHandlers::StatusCureItem.copy(:RAWSTBERRY,:RAWSTBERRY1)
  
  #===============================================================================
  # PriorityBracketChangeItem handlers
  #===============================================================================
  
  BattleHandlers::PriorityBracketChangeItem.add(:CUSTAPBERRY,
    proc { |item,battler,subPri,battle|
      next if !battler.canConsumePinchBerry?
      next 1 if subPri<1
    }
  )
  
  BattleHandlers::PriorityBracketChangeItem.add(:LAGGINGTAIL,
    proc { |item,battler,subPri,battle|
      next -1 if subPri==0
    }
  )
  
  BattleHandlers::PriorityBracketChangeItem.add(:FULLINCENSE,
    proc { |item,battler,subPri,battle|
      next -1 if subPri==0 && $fefieldeffect != 8
    }
  )
  
  BattleHandlers::PriorityBracketChangeItem.add(:QUICKCLAW,
    proc { |item,battler,subPri,battle|
      next 1 if subPri<1 && battle.pbRandom(100)<20
    }
  )
  
  #===============================================================================
  # PriorityBracketUseItem handlers
  #===============================================================================
  
  BattleHandlers::PriorityBracketUseItem.add(:CUSTAPBERRY,
    proc { |item,battler,battle|
      battle.pbCommonAnimation("EatBerry",battler)
      battle.pbDisplay(_INTL("{1}'s {2} let it move first!",battler.pbThis,battler.itemName))
      battler.pbConsumeItem
    }
  )
  
  BattleHandlers::PriorityBracketUseItem.add(:QUICKCLAW,
    proc { |item,battler,battle|
      battle.pbCommonAnimation("UseItem",battler)
      battle.pbDisplay(_INTL("{1}'s {2} let it move first!",battler.pbThis,battler.itemName))
    }
  )
  
  #===============================================================================
  # AccuracyCalcUserItem handlers
  #===============================================================================
  
  BattleHandlers::AccuracyCalcUserItem.add(:WIDELENS,
    proc { |item,mods,user,target,move,types|
      mods[:accuracy_multiplier] *= 1.1
    }
  )
  
  BattleHandlers::AccuracyCalcUserItem.add(:ZOOMLENS,
    proc { |item,mods,user,target,move,types|
      if (target.battle.choices[target.index][0]!=:UseMove &&
         target.battle.choices[target.index][0]!=:Shift) ||
         target.movedThisRound?
        mods[:accuracy_multiplier] *= 1.2
      end
    }
  )
  
  #===============================================================================
  # AccuracyCalcTargetItem handlers
  #===============================================================================
  
  BattleHandlers::AccuracyCalcTargetItem.add(:BRIGHTPOWDER,
    proc { |item,mods,user,target,move,types|
      next if [21,26].include?($fefieldeffect) && target.grounded? || $fefieldeffect == 22
      if [6,9].include?($fefieldeffect)
        mods[:accuracy_multiplier] *= 0.8
      else
        mods[:accuracy_multiplier] *= 0.9
      end
    }
  )
  
  BattleHandlers::AccuracyCalcTargetItem.add(:LAXINCENSE,
    proc { |item,mods,user,target,move,types|
      mods[:accuracy_multiplier] *= 0.9 if $fefieldeffect != 8
    }
  )
  
  #===============================================================================
  # DamageCalcUserItem handlers
  #===============================================================================
  
  BattleHandlers::DamageCalcUserItem.add(:ADAMANTORB,
    proc { |item,user,target,move,mults,baseDmg,types|
      if user.isSpecies?(:DIALGA) && (types.include?(:DRAGON) || types.include?(:STEEL) ||
         $fefieldeffect == 4 && types.include?(:DARK))
        if $fefieldeffect == 4
          mults[:base_damage_multiplier] *= 1.3
        elsif [25,35].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:BLACKBELT,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:FIGHTING)
        if [20,45].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:FISTPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:FIGHTING)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:BLACKGLASSES,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:DARK)
        if $fefieldeffect == 6
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:DREADPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:DARK)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:BUGGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:BUG,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:CHARCOAL,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:base_damage_multiplier] *= 1.2 if types.include?(:FIRE)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:FLAMEPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:FIRE)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:CHOICEBAND,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:attack_multiplier] *= 1.5 if move.physicalMove?
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:CHOICESPECS,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:attack_multiplier] *= 1.5 if move.specialMove?
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:CHOICEDUMPLING,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:attack_multiplier] *= 1.5
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:DARKGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:DARK,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:DEEPSEATOOTH,
    proc { |item,user,target,move,mults,baseDmg,types|
      if (user.isSpecies?(:CLAMPERL) || user.isSpecies?(:HUNTAIL)) && move.specialMove?
        if $fefieldeffect == 22
          mults[:attack_multiplier] *= 2.5
        else
          mults[:attack_multiplier] *= 2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:DRAGONFANG,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:DRAGON)
        if [31,32].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:DRACOPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:DRAGON)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:DRAGONGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:DRAGON,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:ELECTRICGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:ELECTRIC,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:EXPERTBELT,
    proc { |item,user,target,move,mults,baseDmg,types|
      if Effectiveness.super_effective?(target.damageState.typeMod)
        if $fefieldeffect == 45
          mults[:final_damage_multiplier] *= 1.5
        else
          mults[:final_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:FAIRYGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:FAIRY,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:FIGHTINGGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:FIGHTING,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:FIREGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:FIRE,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:FLYINGGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:FLYING,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:GHOSTGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:GHOST,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:GRASSGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:GRASS,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:GRISEOUSORB,
    proc { |item,user,target,move,mults,baseDmg,types|
      if user.isSpecies?(:GIRATINA) && (types.include?(:DRAGON) || types.include?(:GHOST) ||
         types.include?(:DARK) && $fefieldeffect == 4)
        if $fefieldeffect == 4
          mults[:base_damage_multiplier] *= 1.3
        elsif [25,35].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:GROUNDGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:GROUND,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:HARDSTONE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:ROCK) && $fefieldeffect != 7
        if [14,23].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:ROCKINCENSE,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:base_damage_multiplier] *= 1.2 if types.include?(:ROCK) && $fefieldeffect != 8
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:STONEPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:ROCK)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:ICEGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:ICE,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:LIFEORB,
    proc { |item,user,target,move,mults,baseDmg,types|
      if !move.is_a?(PokeBattle_Confusion) && $fefieldeffect != 38
        mults[:final_damage_multiplier] *= 1.3
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:LIGHTBALL,
    proc { |item,user,target,move,mults,baseDmg,types|
      if user.isSpecies?(:PIKACHU)
        mults[:attack_multiplier] *= 2
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:LUSTROUSORB,
    proc { |item,user,target,move,mults,baseDmg,types|
      if user.isSpecies?(:PALKIA) && (types.include?(:DRAGON) || types.include?(:WATER) ||
         $fefieldeffect == 4 && types.include?(:DARK))
        if $fefieldeffect == 4
          mults[:base_damage_multiplier] *= 1.3
        elsif [25,35].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:MAGNET,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:ELECTRIC) && ![38,39].include?($fefieldeffect)
        if [17,18,25,30].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:ZAPPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:ELECTRIC)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:METALCOAT,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:STEEL)
        if $fefieldeffect == 30
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:IRONPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:STEEL)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:METRONOME,
    proc { |item,user,target,move,mults,baseDmg,types|
      met = 1 + 0.2 * [user.effects[PBEffects::Metronome], 5].min
      mults[:final_damage_multiplier] *= met
      if $fefieldeffect == 6
        mults[:final_damage_multiplier] *= met
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:MIRACLESEED,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:GRASS) && $fefieldeffect != 10
        if [2,33].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:ROSEINCENSE,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:base_damage_multiplier] *= 1.2 if types.include?(:GRASS) && $fefieldeffect != 8
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:MEADOWPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:GRASS)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:MUSCLEBAND,
    proc { |item,user,target,move,mults,baseDmg,types|
      if move.physicalMove?
        if $fefieldeffect == 45
          mults[:base_damage_multiplier] *= 1.3
        else
          mults[:base_damage_multiplier] *= 1.1
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:MYSTICWATER,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:WATER)
        if [21,22].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:SEAINCENSE,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:base_damage_multiplier] *= 1.2 if types.include?(:WATER) && $fefieldeffect != 8
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:WAVEINCENSE,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:base_damage_multiplier] *= 1.2 if types.include?(:WATER) && $fefieldeffect != 8
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:SPLASHPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:WATER)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:NEVERMELTICE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:ICE)
        if [13,46].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:ICICLEPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:ICE)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:NORMALGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:NORMAL,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:PIXIEPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:FAIRY)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:POISONBARB,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:POISON)
        if $fefieldeffect == 12
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:TOXICPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:POISON)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:POISONGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:POISON,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:PSYCHICGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:PSYCHIC,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:ROCKGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:ROCK,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:SHARPBEAK,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:FLYING)
        if [15,47].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:SKYPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:FLYING)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:SILKSCARF,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:base_damage_multiplier] *= 1.2 if types.include?(:NORMAL)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:SILVERPOWDER,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:base_damage_multiplier] *= 1.2 if types.include?(:BUG) && !([21,26].include?($fefieldeffect) &&
                                               user.grounded?) && $fefieldeffect != 22
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:INSECTPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:BUG)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:SOFTSAND,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:GROUND) && !([21,26].include?($fefieldeffect) && user.grounded?) &&
         $fefieldeffect != 22
        if [12,20,48,49].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:EARTHPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:GROUND)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:SOULDEW,
    proc { |item,user,target,move,mults,baseDmg,types|
      next if !user.isSpecies?(:LATIAS) && !user.isSpecies?(:LATIOS)
      if Settings::SOUL_DEW_POWERS_UP_TYPES && $fefieldeffect != 29
        mults[:final_damage_multiplier] *= 1.2 if types.include?(:PSYCHIC) || types.include?(:DRAGON)
      else
        if move.specialMove?
          mults[:attack_multiplier] *= 1.5
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:SPELLTAG,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:GHOST)
        if $fefieldeffect == 40
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:SPOOKYPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:GHOST)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:STEELGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:STEEL,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:THICKCLUB,
    proc { |item,user,target,move,mults,baseDmg,types|
      if (user.isSpecies?(:CUBONE) || user.isSpecies?(:MAROWAK)) && move.physicalMove?
        mults[:attack_multiplier] *= 2
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:TWISTEDSPOON,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:PSYCHIC)
        if [6,19,37].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:ODDINCENSE,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:base_damage_multiplier] *= 1.2 if types.include?(:PSYCHIC) && $fefieldeffect != 8
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:MINDPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:PSYCHIC)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:WATERGEM,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleGem(user,:WATER,move,mults,types)
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:WISEGLASSES,
    proc { |item,user,target,move,mults,baseDmg,types|
      if move.specialMove?
        if [5,29,37].include?($fefieldeffect)
          mults[:base_damage_multiplier] *= 1.3
        else
          mults[:base_damage_multiplier] *= 1.1
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:ASSAULTVEST,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:attack_multiplier] *= 1.5 if move.physicalMove? && $fefieldeffect == 45
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:FLAMEORB,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:attack_multiplier] *= 1.3 if move.specialMove? && $fefieldeffect == 42
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:TOXICORB,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:attack_multiplier] *= 1.3 if move.physicalMove? && $fefieldeffect == 42
    }
  )
  
  BattleHandlers::DamageCalcUserItem.add(:BLANKPLATE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if types.include?(:NORMAL)
        if $fefieldeffect == 29
          mults[:base_damage_multiplier] *= 1.5
        else
          mults[:base_damage_multiplier] *= 1.2
        end
      end
    }
  )
  
  #===============================================================================
  # DamageCalcTargetItem handlers
  #===============================================================================
  # NOTE: Species-specific held items consider the original species, not the
  #       transformed species, and still work while transformed. The exceptions
  #       are Metal/Quick Powder, which don't work if the holder is transformed.
  
  BattleHandlers::DamageCalcTargetItem.add(:ASSAULTVEST,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:defense_multiplier] *= 1.5 if move.specialMove? && $fefieldeffect != 45
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:BABIRIBERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:STEEL,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:CHARTIBERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:ROCK,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:CHILANBERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:NORMAL,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:CHOPLEBERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:FIGHTING,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:COBABERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:FLYING,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:COLBURBERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:DARK,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:DEEPSEASCALE,
    proc { |item,user,target,move,mults,baseDmg,types|
      if (target.isSpecies?(:CLAMPERL) || target.isSpecies?(:GOREBYSS)) && move.specialMove?
        if $fefieldeffect == 22
          mults[:defense_multiplier] *= 2.5
        else
          mults[:defense_multiplier] *= 2
        end
      end
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:EVIOLITE,
    proc { |item,user,target,move,mults,baseDmg,types|
      # NOTE: Eviolite cares about whether the Pokémon itself can evolve, which
      #       means it also cares about the Pokémon's form. Some forms cannot
      #       evolve even if the species generally can, and such forms are not
      #       affected by Eviolite.
      if target.pokemon.species_data.get_evolutions(true).length > 0
        mults[:defense_multiplier] *= 1.5
      end
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:HABANBERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:DRAGON,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:KASIBBERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:GHOST,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:KEBIABERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:POISON,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:METALPOWDER,
    proc { |item,user,target,move,mults,baseDmg,types|
      if target.isSpecies?(:DITTO) && !([21,26].include?($fefieldeffect) && target.grounded?) && 
         $fefieldeffect != 22
        mults[:defense_multiplier] *= 1.5
      end
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:OCCABERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:FIRE,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:PASSHOBERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:WATER,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:PAYAPABERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:PSYCHIC,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:RINDOBERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:GRASS,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:ROSELIBERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:FAIRY,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:SHUCABERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:GROUND,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:SOULDEW,
    proc { |item,user,target,move,mults,baseDmg,types|
      next if Settings::SOUL_DEW_POWERS_UP_TYPES && $fefieldeffect != 29
      next if !target.isSpecies?(:LATIAS) && !target.isSpecies?(:LATIOS)
      if move.specialMove?
        mults[:defense_multiplier] *= 1.5
      end
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:TANGABERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:BUG,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:WACANBERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:ELECTRIC,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:YACHEBERRY,
    proc { |item,user,target,move,mults,baseDmg,types|
      pbBattleTypeWeakingBerry(:ICE,types,target,mults)
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:FOCUSBAND,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:base_damage_multiplier] *= 0.5 if move.chessMove?(user) && $fefieldeffect == 5
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:FOCUSSASH,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:base_damage_multiplier] *= 0.5 if move.chessMove?(user) && $fefieldeffect == 5
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:PROTECTIVEPADS,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:defense_multiplier] *= 1.2 if move.physicalMove? && $fefieldeffect == 45
    }
  )
  
  BattleHandlers::DamageCalcTargetItem.add(:CHOICEDUMPLING,
    proc { |item,user,target,move,mults,baseDmg,types|
      mults[:attack_multiplier] *= 1.5
    }
  )
  
  #===============================================================================
  # CriticalCalcUserItem handlers
  #===============================================================================
  
  BattleHandlers::CriticalCalcUserItem.add(:LUCKYPUNCH,
    proc { |item,user,target,c|
      if user.isSpecies?(:CHANSEY) || user.isSpecies?(:BLISSEY)
        if $fefieldeffect == 45
          next c+3
        else
          next c+2
        end
      end
    }
  )
  
  BattleHandlers::CriticalCalcUserItem.add(:RAZORCLAW,
    proc { |item,user,target,c|
      next c+1
    }
  )
  
  BattleHandlers::CriticalCalcUserItem.copy(:RAZORCLAW,:SCOPELENS)
  
  BattleHandlers::CriticalCalcUserItem.add(:STICK,
    proc { |item,user,target,c|
      next c+2 if user.isSpecies?(:FARFETCHD) || user.isSpecies?(:SIRFETCHD)
    }
  )
  
  BattleHandlers::CriticalCalcUserItem.copy(:STICK,:LEEK)
  
  #===============================================================================
  # CriticalCalcTargetItem handlers
  #===============================================================================
  
  # There aren't any!
  
  #===============================================================================
  # TargetItemOnHit handlers
  #===============================================================================
  
  BattleHandlers::TargetItemOnHit.add(:ABSORBBULB,
    proc { |item,user,target,move,battle|
      next if !(move.calcTypes.include?(:WATER) || $fefieldeffect == 3 && move.calcTypes.include?(:FAIRY))
      next if !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
      next if [7,10,12].include?($fefieldeffect)
      battle.pbCommonAnimation("UseItem",target)
      if [2,15,33].include?($fefieldeffect)
        target.pbRaiseStatStageByCause(:SPECIAL_ATTACK,2,target,target.itemName)
      elsif $fefieldeffect == 42
        target.pbRaiseStatStageByCause(battle.generateRandomStat,2,target,target.itemName)
      elsif $fefieldeffect == 47
        target.pbRaiseStatStageByCause([:ATTACK,:SPECIAL_ATTACK],1,target,target.itemName)
      else
        target.pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,target,target.itemName)
      end
      if $fefieldeffect == 8
        target.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,2,target,target.itemName)
      elsif $fefieldeffect == 11 && target.pbCanPoison?(nil,false)
        target.pbPoison(nil,nil,true)
      elsif $fefieldeffect == 19
        target.pbCheckAndInflictRandomStatus
      end
      target.pbHeldItemTriggered(item)
    }
  )
  
  BattleHandlers::TargetItemOnHit.add(:AIRBALLOON,
    proc { |item,user,target,move,battle|
      battle.pbDisplay(_INTL("{1}'s {2} popped!",target.pbThis,target.itemName))
      target.pbConsumeItem(false,true)
      target.pbSymbiosis
    }
  )
  
  BattleHandlers::TargetItemOnHit.add(:CELLBATTERY,
    proc { |item,user,target,move,battle|
      next if !move.calcTypes.include?(:ELECTRIC)
      next if !target.pbCanRaiseStatStage?(:ATTACK,target)
      battle.pbCommonAnimation("UseItem",target)
      if [1,17].include?($fefieldeffect)
        target.pbRaiseStatStageByCause(:ATTACK,2,target,target.itemName)
      else
        target.pbRaiseStatStageByCause(:ATTACK,1,target,target.itemName)
      end
      target.pbHeldItemTriggered(item)
    }
  )
  
  BattleHandlers::TargetItemOnHit.add(:ENIGMABERRY,
    proc { |item,user,target,move,battle|
      next if target.damageState.substitute || target.damageState.disguise || target.damageState.iceface
      next if !Effectiveness.super_effective?(target.damageState.typeMod)
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item,target,battle,false)
        target.pbHeldItemTriggered(item)
      end
    }
  )
  
  BattleHandlers::TargetItemOnHit.add(:JABOCABERRY,
    proc { |item,user,target,move,battle|
      next if !target.canConsumeBerry?
      next if !move.physicalMove?
      next if !user.takesIndirectDamage?
      battle.pbCommonAnimation("EatBerry",target)
      battle.scene.pbDamageAnimation(user)
      if target.hasActiveAbility?(:RIPEN) && ![4,10,11,12,38,39,41,46].include?($fefieldeffect)
        if $fefieldeffect == 33 && $fecounter == 4
          user.pbReduceHP(user.totalhp/2,false)
        elsif [2,15,47].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
          user.pbReduceHP(user.totalhp*3/8,false)
        else
          user.pbReduceHP(user.totalhp/4,false)
        end
      elsif battler.hasActiveAbility?(:GLUTTONY) && ([15,47].include?($fefieldeffect) || 
            $fefieldeffect == 33 && $fecounter >= 3)
        user.pbReduceHP(user.totalhp/4,false)
      else
        user.pbReduceHP(user.totalhp/8,false)
      end
      battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!",target.pbThis,
         target.itemName,user.pbThis(true)))
      target.pbHeldItemTriggered(item)
    }
  )
  
  # NOTE: Kee Berry supposedly shouldn't trigger if the user has Sheer Force, but
  #       I'm ignoring this. Weakness Policy has the same kind of effect and
  #       nowhere says it should be stopped by Sheer Force. I suspect this
  #       stoppage is either a false report that no one ever corrected, or an
  #       effect that later changed and wasn't noticed.
  BattleHandlers::TargetItemOnHit.add(:KEEBERRY,
    proc { |item,user,target,move,battle|
      next if !move.physicalMove?
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item,target,battle,false)
        target.pbHeldItemTriggered(item)
      end
    }
  )
  
  BattleHandlers::TargetItemOnHit.add(:LUMINOUSMOSS,
    proc { |item,user,target,move,battle|
      next if !move.calcTypes.include?(:WATER) || [7,10].include?($fefieldeffect)
      next if !target.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,target)
      battle.pbCommonAnimation("UseItem",target)
      if [2,15,33,47].include?($fefieldeffect)
        target.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,2,target,target.itemName)
      elsif $fefieldeffect == 42
        target.pbRaiseStatStageByCause(battle.generateRandomStat,2,target,target.itemName)
      else
        target.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,target,target.itemName)
      end
      target.pbHeldItemTriggered(item)
    }
  )
  
  # NOTE: Maranga Berry supposedly shouldn't trigger if the user has Sheer Force,
  #       but I'm ignoring this. Weakness Policy has the same kind of effect and
  #       nowhere says it should be stopped by Sheer Force. I suspect this
  #       stoppage is either a false report that no one ever corrected, or an
  #       effect that later changed and wasn't noticed.
  BattleHandlers::TargetItemOnHit.add(:MARANGABERRY,
    proc { |item,user,target,move,battle|
      next if !move.specialMove?
      if BattleHandlers.triggerTargetItemOnHitPositiveBerry(item,target,battle,false)
        target.pbHeldItemTriggered(item)
      end
    }
  )
  
  BattleHandlers::TargetItemOnHit.add(:ROCKYHELMET,
    proc { |item,user,target,move,battle|
      next if !move.pbContactMove?(user)
      next if !user.takesIndirectDamage?
      battle.scene.pbDamageAnimation(user)
      if $fefieldeffect == 14
        user.pbReduceHP(user.totalhp/4,false)
      else
        user.pbReduceHP(user.totalhp/6,false)
      end
      battle.pbDisplay(_INTL("{1} was hurt by the {2}!",user.pbThis,target.itemName))
    }
  )
  
  BattleHandlers::TargetItemOnHit.add(:ROWAPBERRY,
    proc { |item,user,target,move,battle|
      next if !target.canConsumeBerry?
      next if !move.specialMove?
      next if !user.takesIndirectDamage?
      battle.pbCommonAnimation("EatBerry",target)
      battle.scene.pbDamageAnimation(user)
      if target.hasActiveAbility?(:RIPEN) && ![4,10,11,12,38,39,41,46].include?($fefieldeffect)
        if $fefieldeffect == 33 && $fecounter == 4
          user.pbReduceHP(user.totalhp/2,false)
        elsif [2,15,47].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
          user.pbReduceHP(user.totalhp*3/8,false)
        else
          user.pbReduceHP(user.totalhp/4,false)
        end
      elsif battler.hasActiveAbility?(:GLUTTONY) && ([15,47].include?($fefieldeffect) || 
            $fefieldeffect == 33 && $fecounter >= 3)
        user.pbReduceHP(user.totalhp/4,false)
      else
        user.pbReduceHP(user.totalhp/8,false)
      end
      battle.pbDisplay(_INTL("{1} consumed its {2} and hurt {3}!",target.pbThis,
         target.itemName,user.pbThis(true)))
      target.pbHeldItemTriggered(item)
    }
  )
  
  BattleHandlers::TargetItemOnHit.add(:SNOWBALL,
    proc { |item,user,target,move,battle|
      next if !move.calcTypes.include?(:ICE) || [7,12,16].include?($fefieldeffect)
      next if !target.pbCanRaiseStatStage?(:ATTACK,target)
      battle.pbCommonAnimation("UseItem",target)
      if [28,46].include?($fefieldeffect)
        target.pbRaiseStatStageByCause(:ATTACK,2,target,target.itemName)
      else
        target.pbRaiseStatStageByCause(:ATTACK,1,target,target.itemName)
      end
      target.pbHeldItemTriggered(item)
    }
  )
  
  BattleHandlers::TargetItemOnHit.add(:STICKYBARB,
    proc { |item,user,target,move,battle|
      next if !move.pbContactMove?(user)
      next if user.fainted? || user.item
      user.item = target.item
      target.item = nil
      target.activateUnburden
      if battle.wildBattle? && !user.opposes?
        if !user.initialItem && target.initialItem==user.item
          user.setInitialItem(user.item)
          target.setInitialItem(nil)
        end
      end
      battle.pbDisplay(_INTL("{1}'s {2} was transferred to {3}!",
         target.pbThis,user.itemName,user.pbThis(true)))
    }
  )
  
  BattleHandlers::TargetItemOnHit.add(:WEAKNESSPOLICY,
    proc { |item,user,target,move,battle|
      next if target.damageState.disguise || target.damageState.iceface
      next if !Effectiveness.super_effective?(target.damageState.typeMod)
      next if !target.pbCanRaiseStatStage?(:ATTACK,target) &&
              !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
      battle.pbCommonAnimation("UseItem",target)
      showAnim = true
      if target.pbCanRaiseStatStage?(:ATTACK,target)
        target.pbRaiseStatStageByCause(:ATTACK,2,target,target.itemName,showAnim)
        showAnim = false
      end
      if target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
        target.pbRaiseStatStageByCause(:SPECIAL_ATTACK,2,target,target.itemName,showAnim)
      end
      target.pbHeldItemTriggered(item)
    }
  )
  
  #===============================================================================
  # TargetItemOnHitPositiveBerry handlers
  # NOTE: This is for berries that have an effect when Pluck/Bug Bite/Fling
  #       forces their use.
  #===============================================================================
  
  BattleHandlers::TargetItemOnHitPositiveBerry.add(:ENIGMABERRY,
    proc { |item,battler,battle,forced|
      next false if !battler.canHeal?
      next false if !forced && !battler.canConsumeBerry?
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      if battler.hasActiveAbility?(:RIPEN) && ![4,10,11,12,38,39,41,46].include?($fefieldeffect)
        if $fefieldeffect == 33 && $fecounter == 4
          battler.pbRecoverHP(battler.totalhp/4)
        elsif [2,15,47].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
          battler.pbRecoverHP(battler.totalhp*3/4)
        else
          battler.pbRecoverHP(battler.totalhp/2)
        end
      elsif battler.hasActiveAbility?(:GLUTTONY) && ([15,47].include?($fefieldeffect) || 
            $fefieldeffect == 33 && $fecounter >= 3)
        battler.pbRecoverHP(battler.totalhp/2)
      else
        battler.pbRecoverHP(battler.totalhp/4)
      end
      if forced
        battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} restored its health using its {2}!",battler.pbThis,
           itemName))
      end
      next true
    }
  )
  
  BattleHandlers::TargetItemOnHitPositiveBerry.add(:KEEBERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      next false if !battler.pbCanRaiseStatStage?(:DEFENSE,battler)
      if battler.hasActiveAbility?(:RIPEN) && ![4,10,11,12,38,39,41,46].include?($fefieldeffect)
        if $fefieldeffect == 33 && $fecounter == 4
          increment = 4
        elsif [2,15,47].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
          increment = 3
        else
          increment = 2
        end
      elsif battler.hasActiveAbility?(:GLUTTONY) && ([15,47].include?($fefieldeffect) || 
            $fefieldeffect == 33 && $fecounter >= 3)
        increment = 2
      else
        increment = 1
      end
      itemName = GameData::Item.get(item).name
      if !forced
        battle.pbCommonAnimation("EatBerry",battler)
        next battler.pbRaiseStatStageByCause(:DEFENSE,increment,battler,itemName)
      end
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
      next battler.pbRaiseStatStage(:DEFENSE,increment,battler)
    }
  )
  
  BattleHandlers::TargetItemOnHitPositiveBerry.add(:MARANGABERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      next false if !battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,battler)
      itemName = GameData::Item.get(item).name
      if battler.hasActiveAbility?(:RIPEN) && ![4,10,11,12,38,39,41,46].include?($fefieldeffect)
        if $fefieldeffect == 33 && $fecounter == 4
          increment = 4
        elsif [2,15,47].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
          increment = 3
        else
          increment = 2
        end
      elsif battler.hasActiveAbility?(:GLUTTONY) && ([15,47].include?($fefieldeffect) || 
            $fefieldeffect == 33 && $fecounter >= 3)
        increment = 2
      else
        increment = 1
      end
      if !forced
        battle.pbCommonAnimation("EatBerry",battler)
        next battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,increment,battler,itemName)
      end
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}")
      next battler.pbRaiseStatStage(:SPECIAL_DEFENSE,increment,battler)
    }
  )
  
  #===============================================================================
  # TargetItemAfterMoveUse handlers
  #===============================================================================
  
  BattleHandlers::TargetItemAfterMoveUse.add(:EJECTBUTTON,
    proc { |item,battler,user,move,switched,battle|
      next if battle.pbAllFainted?(battler.idxOpposingSide)
      next if !battle.pbCanChooseNonActive?(battler.index)
      battle.pbCommonAnimation("UseItem",battler)
      battle.pbDisplay(_INTL("{1} is switched out with the {2}!",battler.pbThis,battler.itemName))
      if $fefieldeffect == 6
        battler.pbRecoverHP(battler.totalhp/4,false,false)
      end
      battler.pbConsumeItem(true,false)
      newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
      next if newPkmn<0
      battle.pbRecallAndReplace(battler.index,newPkmn)
      battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
      switched.push(battler.index)
    }
  )
  
  BattleHandlers::TargetItemAfterMoveUse.add(:REDCARD,
    proc { |item,battler,user,move,switched,battle|
      next if user.fainted? || switched.include?(user.index)
      newPkmn = battle.pbGetReplacementPokemonIndex(user.index,true)   # Random
      next if newPkmn<0
      battle.pbCommonAnimation("UseItem",battler)
      battle.pbDisplay(_INTL("{1} held up its {2} against {3}!",
         battler.pbThis,battler.itemName,user.pbThis(true)))
      battler.pbConsumeItem
      battle.pbRecallAndReplace(user.index, newPkmn, true)
      battle.pbDisplay(_INTL("{1} was dragged out!",user.pbThis))
      battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
      switched.push(user.index)
    }
  )
  
  #===============================================================================
  # UserItemAfterMoveUse handlers
  #===============================================================================
  
  BattleHandlers::UserItemAfterMoveUse.add(:LIFEORB,
    proc { |item,user,targets,move,numHits,battle|
      next if !user.takesIndirectDamage? || [29,38].include?($fefieldeffect)
      next if !move.pbDamagingMove? || numHits==0
      hitBattler = false
      targets.each do |b|
        hitBattler = true if !b.damageState.unaffected && !b.damageState.substitute
        break if hitBattler
      end
      next if !hitBattler
      PBDebug.log("[Item triggered] #{user.pbThis}'s #{user.itemName} (recoil)")
      user.pbReduceHP(user.totalhp/10)
      battle.pbDisplay(_INTL("{1} lost some of its HP!",user.pbThis))
      user.pbItemHPHealCheck
      user.pbFaint if user.fainted?
    }
  )
  
  BattleHandlers::UserItemAfterMoveUse.add(:SHELLBELL,
    proc { |item,user,targets,move,numHits,battle|
      next if !user.canHeal?
      totalDamage = 0
      targets.each { |b| totalDamage += b.damageState.totalHPLost }
      next if totalDamage<=0
      if [20,22,48].include?($fefieldeffect)
        user.pbRecoverHP(totalDamage/4)
      else
        user.pbRecoverHP(totalDamage/8)
      end
      battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",
         user.pbThis,user.itemName))
    }
  )
  
  BattleHandlers::UserItemAfterMoveUse.add(:THROATSPRAY,
    proc { |item,user,targets,move,numHits,battle|
      next if !move.soundMove?(user) || numHits==0
      next if !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user)
      battle.pbCommonAnimation("UseItem",user)
      if $fefieldeffect == 6
        user.pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,user,user.itemName,true)
      else
        user.pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,user,user.itemName,true)
      end
      user.pbConsumeItem
    }
  )
  
  #===============================================================================
  # EndOfMoveItem handlers
  #===============================================================================
  
  BattleHandlers::EndOfMoveItem.add(:LEPPABERRY,
    proc { |item,battler,battle,forced|
      next false if !forced && !battler.canConsumeBerry?
      found = []
      battler.pokemon.moves.each_with_index do |m,i|
        next if m.total_pp<=0 || m.pp==m.total_pp
        next if !forced && m.pp>0
        found.push(i)
      end
      next false if found.length==0
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("EatBerry",battler) if !forced
      choice = found[battle.pbRandom(found.length)]
      pkmnMove = battler.pokemon.moves[choice]
      pkmnMove.pp += 10
      if battler.hasActiveAbility?(:RIPEN) && ![4,10,11,12,38,39,41,46].include?($fefieldeffect)
        pkmnMove.pp += 10
        if [2,15,47].include?($fefieldeffect) || $fefieldeffect == 33 && $fecounter >= 2
          pkmnMove.pp += 10
          if $fefieldeffect == 33 && $fecounter == 4
            pkmnMove.pp += 10
          end
        end
      elsif battler.hasActiveAbility?(:GLUTTONY) && ([15,47].include?($fefieldeffect) || 
            $fefieldeffect == 33 && $fecounter >= 3)
        pkmnMove.pp += 10
      end
      pkmnMove.pp = pkmnMove.total_pp if pkmnMove.pp>pkmnMove.total_pp
      battler.moves[choice].pp = pkmnMove.pp
      moveName = pkmnMove.name
      if forced
        battle.pbDisplay(_INTL("{1} restored its {2}'s PP.",battler.pbThis,moveName))
      else
        battle.pbDisplay(_INTL("{1}'s {2} restored its {3}'s PP!",battler.pbThis,itemName,moveName))
      end
      next true
    }
  )
  
  BattleHandlers::EndOfMoveItem.copy(:LEPPABERRY,:LEPPABERRY1)
  
  #===============================================================================
  # EndOfMoveStatRestoreItem handlers
  #===============================================================================
  
  BattleHandlers::EndOfMoveStatRestoreItem.add(:WHITEHERB,
    proc { |item,battler,battle,forced|
      reducedStats = false
      GameData::Stat.each_battle do |s|
        next if battler.stages[s.id] >= 0
        battler.stages[s.id] = 0
        reducedStats = true
      end
      next false if !reducedStats
      itemName = GameData::Item.get(item).name
      PBDebug.log("[Item triggered] #{battler.pbThis}'s #{itemName}") if forced
      battle.pbCommonAnimation("UseItem",battler) if !forced
      if forced
        battle.pbDisplay(_INTL("{1}'s status returned to normal!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1} returned its status to normal using its {2}!",
           battler.pbThis,itemName))
      end
      next true
    }
  )
  
  #===============================================================================
  # ExpGainModifierItem handlers
  #===============================================================================
  
  BattleHandlers::ExpGainModifierItem.add(:LUCKYEGG,
    proc { |item,battler,exp|
      next exp*3/2
    }
  )
  
  #===============================================================================
  # EVGainModifierItem handlers
  #===============================================================================
  
  BattleHandlers::EVGainModifierItem.add(:MACHOBRACE,
    proc { |item,battler,evYield|
      evYield.each_key { |stat| evYield[stat] *= 2 }
    }
  )
  
  BattleHandlers::EVGainModifierItem.add(:POWERANKLET,
    proc { |item,battler,evYield|
      evYield[:SPEED] += 4
    }
  )
  
  BattleHandlers::EVGainModifierItem.add(:POWERBAND,
    proc { |item,battler,evYield|
      evYield[:SPECIAL_DEFENSE] += 4
    }
  )
  
  BattleHandlers::EVGainModifierItem.add(:POWERBELT,
    proc { |item,battler,evYield|
      evYield[:DEFENSE] += 4
    }
  )
  
  BattleHandlers::EVGainModifierItem.add(:POWERBRACER,
    proc { |item,battler,evYield|
      evYield[:ATTACK] += 4
    }
  )
  
  BattleHandlers::EVGainModifierItem.add(:POWERLENS,
    proc { |item,battler,evYield|
      evYield[:SPECIAL_ATTACK] += 4
    }
  )
  
  BattleHandlers::EVGainModifierItem.add(:POWERWEIGHT,
    proc { |item,battler,evYield|
      evYield[:HP] += 4
    }
  )
  
  BattleHandlers::EVGainModifierItem.add(:ENERGYANKLET,
    proc { |item,battler,evYield|
      sum = 0
      evYield.each_key { |stat| 
        sum += evYield[stat]
        evYield[stat] = 0
      }
      evYield[:SPEED] = sum
    }
  )
  
  BattleHandlers::EVGainModifierItem.add(:ENERGYBAND,
    proc { |item,battler,evYield|
      sum = 0
      evYield.each_key { |stat| 
        sum += evYield[stat]
        evYield[stat] = 0
      }
      evYield[:SPECIAL_DEFENSE] = sum
    }
  )
  
  BattleHandlers::EVGainModifierItem.add(:ENERGYBELT,
    proc { |item,battler,evYield|
      sum = 0
      evYield.each_key { |stat| 
        sum += evYield[stat]
        evYield[stat] = 0
      }
      evYield[:DEFENSE] = sum
    }
  )
  
  BattleHandlers::EVGainModifierItem.add(:ENERGYBRACER,
    proc { |item,battler,evYield|
      sum = 0
      evYield.each_key { |stat| 
        sum += evYield[stat]
        evYield[stat] = 0
      }
      evYield[:ATTACK] = sum
    }
  )
  
  BattleHandlers::EVGainModifierItem.add(:ENERGYLENS,
    proc { |item,battler,evYield|
      sum = 0
      evYield.each_key { |stat| 
        sum += evYield[stat]
        evYield[stat] = 0
      }
      evYield[:SPECIAL_ATTACK] = sum
    }
  )
  
  BattleHandlers::EVGainModifierItem.add(:ENERGYWEIGHT,
    proc { |item,battler,evYield|
      sum = 0
      evYield.each_key { |stat| 
        sum += evYield[stat]
        evYield[stat] = 0
      }
      evYield[:HP] = sum
    }
  )
  
  #===============================================================================
  # WeatherExtenderItem handlers
  #===============================================================================
  
  BattleHandlers::WeatherExtenderItem.add(:DAMPROCK,
    proc { |item,weather,duration,battler,battle|
      next (duration*1.5).ceil if weather == :Rain
    }
  )
  
  BattleHandlers::WeatherExtenderItem.add(:HEATROCK,
    proc { |item,weather,duration,battler,battle|
      next (duration*1.5).ceil if weather == :Sun
    }
  )
  
  BattleHandlers::WeatherExtenderItem.add(:ICYROCK,
    proc { |item,weather,duration,battler,battle|
      next (duration*1.5).ceil if weather == :Hail
    }
  )
  
  BattleHandlers::WeatherExtenderItem.add(:SMOOTHROCK,
    proc { |item,weather,duration,battler,battle|
      next (duration*1.5).ceil if weather == :Sandstorm
    }
  )
  
  #===============================================================================
  # TerrainExtenderItem handlers
  #===============================================================================
  
  BattleHandlers::TerrainExtenderItem.add(:TERRAINEXTENDER,
    proc { |item,terrain,duration,battler,battle|
      next (duration*1.5).ceil
    }
  )
  
  #===============================================================================
  # TerrainStatBoostItem handlers
  #===============================================================================
  
  BattleHandlers::TerrainStatBoostItem.add(:ELEMENTALSEED,
    proc { |item,battler,battle|
      itemName = GameData::Item.get(item).name
      case $fefieldeffect
      when 1 # Electric Terrain
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:SPEED,1,battler,itemName)
        battler.effects[PBEffects::Charge]=1
        battle.pbAnimation(:CHARGE,battler,nil)
        battle.pbDisplay(_INTL("{1} began charging power!",battler.pbThis))
      when 2 # Grassy Terrain
        battle.pbCommonAnimation("UseItem",battler)
        battler.effects[PBEffects::Substitute] = [battler.totalhp/4,1].max
        battle.pbDisplay(_INTL("{1} put in a substitute!",battler.pbThis))
        battle.pbAnimation(:YAWN,battler,battler)
        battle.effects[PBEffects::Yawn] = 1
        battle.pbDisplay(_INTL("{1} became drowsy!",battler.pbThis))
      when 3 # Misty Terrain
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:DEFENSE,:SPECIAL_DEFENSE],2,battler,itemName)
        if !battler.aromaVeilProtected?
          battle.pbDisplay(_INTL("{1} was prevented from healing!",battler.pbThis))
          battler.effects[PBEffects::HealBlock]=4
          battle.pbAnimation(:HEALBLOCK,battler,nil)
        end
      when 7 # Burning Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:ATTACK,:SPECIAL_ATTACK,:SPEED],1,battler,itemName)
        battler.effects[PBEffects::Trapping] = 5+battle.pbRandom(2)
        battler.effects[PBEffects::TrappingMove] = :FIRESPIN
        battler.effects[PBEffects::TrappingUser] = battler.index
        battle.pbAnimation(:FIRESPIN,battler,nil)
        battle.pbDisplay(_INTL("{1} was trapped in the fiery vortex!",battler.pbThis))
      when 11 # Corrosive Mist Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:ATTACK,:SPECIAL_ATTACK,:SPEED],1,battler,itemName)
        if battler.pbCanPoison?(nil,false)  
          battler.pbPoison(nil,nil,true)
        end
      when 21 # Water Surface
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,battler,itemName)
        battler.effects[PBEffects::AquaRing]=true
        battle.pbAnimation(:AQUARING,battler,nil)
        battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",battler.pbThis))
      when 22 # Underwater
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:SPEED,2,battler,itemName)
        if battler.canChangeType? && battler.pbHasOtherType?(:WATER)
          battler.pbChangeTypes(:WATER)
          typeName = GameData::Type.get(:WATER).name
          battle.pbAnimation(:SOAK,battler,nil)
          battle.pbDisplay(_INTL("{1} transformed into the {2} type!",battler.pbThis,typeName))
        end
      when 26 # Murkwater Surface
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,3,battler,itemName)
        battler.effects[PBEffects::AquaRing]=true
        battle.pbAnimation(:AQUARING,battler,nil)
        battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",battler.pbThis))          
        if battler.canChangeType? && battler.pbHasOtherType?(:WATER)
          battler.pbChangeTypes(:WATER)
          typeName = GameData::Type.get(:WATER).name
          battle.pbAnimation(:SOAK,battler,nil)
          battle.pbDisplay(_INTL("{1} transformed into the {2} type!",battler.pbThis,typeName))
        end
        if battler.pbCanPoison?(nil,false)
          battler.pbPoison(nil,nil,true)
        end
      when 32 # Dragon's Den
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,battler,itemName)
        battler.effects[PBEffects::FlashFire]=true
        battle.pbDisplay(_INTL("{1} raised its Fire power!",battler.pbThis))
      when 39 # Frozen Dimensional Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:ATTACK,2,battler,itemName)
        battler.effects[PBEffects::CriticalBoost] += 1
        battle.pbDisplay(_INTL("{1}'s {2} boosted its critical hit ratio!",battler.pbThis,itemName))
        if battler.pbCanConfuseSelf?(false)
          battler.pbConfuse
        end
      when 43 # Sky Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbLowerStatStageByCause([:DEFENSE,:SPECIAL_DEFENSE],1,battler,itemName)
        battler.pbOwnSide.effects[PBEffects::Tailwind]=7
        battle.pbAnimation(:TAILWIND,battler,nil)
        battle.pbDisplay(_INTL("The tailwind blew from behind {1}!",battler.pbTeam(true)))
      when 46 # Subzero
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:EVASION,:DEFENSE],1,battler,itemName)
      else
        next false
      end
      next true
    }
  )
  
  BattleHandlers::TerrainStatBoostItem.add(:MAGICALSEED,
    proc { |item,battler,battle|
      itemName = GameData::Item.get(item).name
      case $fefieldeffect
      when 4 # Dark Crystal Cavern
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbLowerStatStageByCause(:ACCURACY,6,battler,itemName)
        battler.effects[PBEffects::Spotlight]=1
        battle.pbAnimation(:SPOTLIGHT,battler,battler)
        battle.pbDisplay(_INTL("{1} became the center of attention!",battler.pbThis))
      when 9 # Rainbow Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:SPECIAL_DEFENSE,:SPEED],1,battler,itemName)
        type = battle.generateRandomType
        if battler.canChangeType? && battler.pbHasOtherType?(type)
          battler.pbChangeTypes(type)
          typeName = GameData::Type.get(type).name
          battle.pbAnimation(:CAMOUFLAGE,battler,nil)
          battle.pbDisplay(_INTL("{1} transformed into the {2} type!",battler.pbThis,typeName))
        end
      when 19 # Wasteland
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:ATTACK,:SPECIAL_ATTACK,:SPEED],1,battler,itemName)
        battler.pbCheckAndInflictRandomStatus
      when 25 # Crystal Cavern
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,battler,itemName)
        type = battle.crystalType
        if battler.canChangeType? && battler.pbHasOtherType?(type)
          battler.pbChangeTypes(type)
          typeName = GameData::Type.get(type).name
          battle.pbAnimation(:CAMOUFLAGE,battler,nil)
          battle.pbDisplay(_INTL("{1} transformed into the {2} type!",battler.pbThis,typeName))
        end
      when 29 # Holy Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,battler,itemName)
        battler.effects[PBEffects::MagicCoat]=true
        battle.pbAnimation(:MAGICCOAT,battler,nil)
        battle.pbDisplay(_INTL("{1} shrouded itself with Magic Coat!",battler.pbThis))
      when 31 # Fairy Tale Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbLowerStatStageByCause(:SPECIAL_ATTACK,1,battler,itemName)
        battler.effects[PBEffects::KingsShield]=true
        battle.pbAnimation(:KINGSSHIELD,battler,nil)
        battle.pbDisplay(_INTL("{1} shielded itself against damage!",battler.pbThis))
      when 34 # Starlight Arena
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,battler,itemName)
        battle.positions[battler.index].effects[PBEffects::Wish] = 1
        battle.positions[battler.index].effects[PBEffects::WishAmount] = (battler.totalhp/2.0).round
        battle.positions[battler.index].effects[PBEffects::WishMaker] = battler.pokemonIndex
        battle.pbAnimation(:WISH,battler,nil)
        battle.pbDisplay(_INTL("{1} wished upon a star!",battler.pbThis))
      when 35 # Ultra Space
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:DEFENSE,:SPECIAL_DEFENSE],1,battler,itemName)
        battle.field.effects[PBEffects::WonderRoom]=7
        battle.pbAnimation(:WONDERROOM,battler,nil)
        battle.pbDisplay(_INTL("{1} created a Wonder Room, swapping the defenses of all Pokémon!",battler.pbThis))
      when 37 # Psychic Terrain
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED],1,battler,itemName)
        if battler.pbCanConfuseSelf?(false)
          battler.pbConfuse
        end
      when 38 # Dimensional Field
        battle.pbCommonAnimation("UseItem",battler)
        if battle.field.effects[PBEffects::TrickRoom] == 0
          battle.field.effects[PBEffects::TrickRoom]=2+pbRandom(6)
          battle.pbAnimation(:TRICKROOM,battler,nil)
          battle.pbDisplay(_INTL("{1}'s Magical Seed twisted the dimensions!",battler.pbThis))
        else
          battle.field.effects[PBEffects::TrickRoom]=0
          battle.pbAnimation(:TRICKROOM,battler,nil)
          battle.pbDisplay(_INTL("{1}'s Magical Seed reverted the dimensions!",battler.pbThis))
        end
      when 40 # Haunted Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:DEFENSE,:SPECIAL_DEFENSE,:EVASION],1,battler,itemName)
        if battler.pbCanBurn?(nil,false)
          battler.pbBurn
        end
      when 42 # Bewitched Woods
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,battler,itemName)
        battler.effects[PBEffects::Ingrain]=true
        battle.pbAnimation(:INGRAIN,battler,nil)
        battle.pbDisplay(_INTL("{1} planted its roots!",battler.pbThis))
        battler.pbCheckAndInflictRandomStatus
      else
        next false
      end
      next true
    }
  )
  
  BattleHandlers::TerrainStatBoostItem.add(:SYNTHETICSEED,
    proc { |item,battler,battle|
      itemName = GameData::Item.get(item).name
      case $fefieldeffect
      when 5 # Chess Board
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbLowerStatStageByCause(:SPECIAL_DEFENSE,1,battler,itemName)
        battler.effects[PBEffects::Obstruct]=true
        battle.pbAnimation(:OBSTRUCT,battler,nil)
        battle.pbDisplay(_INTL("{1} protected itself!",battler.pbThis))
      when 6 # Performance Stage
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:ATTACK,1,battler,itemName)
        battler.effects[PBEffects::HelpingHand]=true
        battle.pbAnimation(:HELPINGHAND,battler,battler)
        battle.pbDisplay(_INTL("{1} accepts the crowd's help!",battler.pbThis))
      when 17 # Factory Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:ACCURACY,1,battler,itemName)
        battler.effects[PBEffects::LaserFocus]=1
        battle.pbAnimation(:LASERFOCUS,battler,nil)
        battle.pbDisplay(_INTL("{1} concentrated intensely!",battler.pbThis))
      when 18 # Short-Circuit Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,battler,itemName)
        battler.effects[PBEffects::MagnetRise]=7
        battle.pbAnimation(:MAGNETRISE,battler,nil)
        battle.pbDisplay(_INTL("{1} levitated with electromagnetism!",battler.pbThis))
      when 24 # Glitch
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(battle.generateRandomStat,2,battler,itemName)
        if battler.canChangeType? && battler.pbHasOtherType?(:QMARKS)
          battler.pbChangeTypes(:QMARKS)
          typeName = GameData::Type.get(:QMARKS).name
          battle.pbAnimation(:CAMOUFLAGE,battler,nil)
          battle.pbDisplay(_INTL("{1} transformed into the {2} type!",battler.pbThis,typeName))
        end
      when 30 # Mirror Arena
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:EVASION,2,battler,itemName)
      when 33 # Flower Garden
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,battler,itemName)
        if ![:TRUANT,:INSOMNIA].include?(battler.ability_id)
          battler.pbSetAbility(:INSOMNIA,:WORRYSEED)
        end
        battle.changeFlowerGardenStage(1)
      when 36 # Inverse Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbSetAbility(:CONTRARY)
        battler.effects[PBEffects::CriticalBoost] += 1
        battle.pbDisplay(_INTL("{1}'s {2} boosted its critical hit ratio!",battler.pbThis,itemName))
      when 41 # Corrupted Cave
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:DEFENSE,2,battler,itemName)
        battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,battler,itemName)
        if battler.pbCanPoison?(nil,false)
          battler.pbPoison
        end
      when 44 # Indoors
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbLowerStatStageByCause(:SPEED,1,battler,itemName)
        battler.effects[PBEffects::Protect]=true
        battle.pbAnimation(:PROTECT,battler,nil)
        battle.pbDisplay(_INTL("{1} shielded itself against damage!",battler.pbThis))
      when 45 # Boxing Ring
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:ATTACK,1,battler,itemName)
        battler.effects[PBEffects::Endure]=true
        battle.pbAnimation(:ENDURE,battler,nil)
        battle.pbDisplay(_INTL("{1} is ready to endure an attack!",battler.pbThis))
      else
        next false
      end
      next true
    }
  )
  
  BattleHandlers::TerrainStatBoostItem.add(:TELLURICSEED,
    proc { |item,battler,battle|
      itemName = GameData::Item.get(item).name
      case $fefieldeffect
      when 8 # Swamp Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:ATTACK,2,battler,itemName)
        battler.effects[PBEffects::Ingrain]=true
        battle.pbAnimation(:INGRAIN,battler,nil)
        battle.pbDisplay(_INTL("{1} planted its roots!",battler.pbThis))
      when 10 # Corrosive Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.effects[PBEffects::BanefulBunker]=true
        battle.pbAnimation(:BANEFULBUNKER,battler,nil)
        battle.pbDisplay(_INTL("{1}'s Telluric Seed shielded itself against damage!",battler.pbThis))
        battler.pbReduceHP(battler.totalhp/8)
      when 12 # Desert Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:DEFENSE,:SPECIAL_DEFENSE,:SPEED,:ACCURACY],1,battler,itemName)
        battler.effects[PBEffects::Trapping] = 5+battle.pbRandom(2)
        battler.effects[PBEffects::TrappingMove] = :SANDTOMB
        battler.effects[PBEffects::TrappingUser] = battler.index
        battle.pbAnimation(:SANDTOMB,battler,nil)
        battle.pbDisplay(_INTL("{1} was trapped by Sand Tomb!",battler.pbThis))
      when 13 # Icy Cave
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:SPEED,2,battler,itemName)
      when 14 # Rocky Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:DEFENSE,2,battler,itemName)
        battler.pbRaiseStatStageByCause(:SPECIAL_DEFENSE,1,battler,itemName)
        if !battler.pbOwnSide.effects[PBEffects::StealthRock]
          battler.pbOwnSide.effects[PBEffects::StealthRock] = true
          battle.pbDisplay(_INTL("Pointed stones float in the air around {1}!",battler.pbTeam(true)))
        end
      when 15 # Forest Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:EVASION,1,battler,itemName)
        battler.effects[PBEffects::Ingrain]=true
        battle.pbAnimation(:INGRAIN,battler,nil)
        battle.pbDisplay(_INTL("{1} planted its roots!",battler.pbThis))
      when 16 # Volcanic Top Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:SPECIAL_ATTACK,2,battler,itemName)
        battler.pbRaiseStatStageByCause(:DEFENSE,1,battler,itemName)
        battler.pbLowerStatStageByCause(:ACCURACY,1,battler,itemName)
      when 20 # Ashen Beach
        battle.pbCommonAnimation("UseItem",battler)
        if !(battler.effects[PBEffects::FocusEnergy]>=2)
          battler.effects[PBEffects::FocusEnergy]=2
          battle.pbAnimation(:FOCUSENERGY,battler,nil)
          battle.pbDisplay(_INTL("{1}'s {2} is getting it pumped!",battler.pbThis,itemName))
        end
        battler.effects[PBEffects::LaserFocus]=1
        battle.pbAnimation(:LASERFOCUS,battler,nil)
        battle.pbDisplay(_INTL("{1} concentrated intensely!",battler.pbThis))
      when 23 # Cave Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause(:DEFENSE,3,battler,itemName)
        if battler.takesIndirectDamage?
          bTypes = battler.pbTypes(true)
          eff = Effectiveness.calculate(:ROCK, bTypes[0], bTypes[1], bTypes[2])
          if !Effectiveness.ineffective?(eff)
            eff = eff.to_f / Effectiveness::NORMAL_EFFECTIVE
            oldHP = battler.hp
            if battler.pbReduceHP(battler.totalhp*eff/8,false) > 0
              battle.pbDisplay(_INTL("Pointed stones dug into {1}!",battler.pbThis))
            end
          end
        end
      when 27 # Mountain
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:ATTACK,:ACCURACY],1,battler,itemName)
      when 28 # Snowy Mountain
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:SPECIAL_ATTACK,:ACCURACY],1,battler,itemName)
      when 47 # Jungle
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:ATTACK,:SPECIAL_ATTACK,:SPEED],1,battler,itemName)
        if !battler.pbOwnSide.effects[PBEffects::StickyWeb]
          battle.pbAnimation(:STICKYWEB,battler.pbDirectOpposing,battler.pbDirectOpposing) # Animates on holder's side
          battler.pbOwnSide.effects[PBEffects::StickyWeb] = true
          batter.pbOwnSide.effects[PBEffects::StickyWebUser] = battler.index
          battle.pbDisplay(_INTL("A sticky web has been laid out beneath {1}'s feet!",battler.pbTeam(true)))
        end
      when 48 # Beach Field
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbRaiseStatStageByCause([:SPECIAL_ATTACK,:SPECIAL_DEFENSE],2,battler,itemName)
        battle.pbAnimation(:YAWN,battler,battler)
        battle.effects[PBEffects::Yawn] = 1
        battle.pbDisplay(_INTL("{1} became drowsy!",battler.pbThis))
      when 49 # Xeric Shrubland
        battle.pbCommonAnimation("UseItem",battler)
        battler.pbLowerStatStageByCause(:SPEED,1,battler,itemName)
        battler.effects[PBEffects::SpikyShield]=true
        battle.pbAnimation(:SPIKYSHIELD,battler,nil)
        battle.pbDisplay(_INTL("{1}'s {2} shielded itself against damage!",battler.pbThis,itemName))
      else
        next false
      end
      next true
    }
  )
  
  #===============================================================================
  # EORHealingItem handlers
  #===============================================================================
  
  BattleHandlers::EORHealingItem.add(:BLACKSLUDGE,
    proc { |item,battler,battle|
      if battler.pbHasType?(:POISON)
        next if !battler.canHeal?
        battle.pbCommonAnimation("UseItem",battler)
        if [19,26,41].include?($fefieldeffect)
          battler.pbRecoverHP(battler.totalhp/8)
        else
          battler.pbRecoverHP(battler.totalhp/16)
        end
        battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",
           battler.pbThis,battler.itemName))
      elsif battler.takesIndirectDamage?
        oldHP = battler.hp
        battle.pbCommonAnimation("UseItem",battler)
        if [19,26,41].include?($fefieldeffect)
          battler.pbReduceHP(battler.totalhp/4)
        else
          battler.pbReduceHP(battler.totalhp/8)
        end
        battle.pbDisplay(_INTL("{1} is hurt by its {2}!",battler.pbThis,battler.itemName))
        battler.pbItemHPHealCheck
        battler.pbAbilitiesOnDamageTaken(oldHP)
        battler.pbFaint if battler.fainted?
      end
    }
  )
  
  BattleHandlers::EORHealingItem.add(:LEFTOVERS,
    proc { |item,battler,battle|
      next if !battler.canHeal? || $fefieldeffect == 22
      battle.pbCommonAnimation("UseItem",battler)
      if $fefieldeffect == 12
        battler.pbRecoverHP(battler.totalhp/8)
      else
        battler.pbRecoverHP(battler.totalhp/16)
      end
      battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!",
         battler.pbThis,battler.itemName))
    }
  )
  
  #===============================================================================
  # EOREffectItem handlers
  #===============================================================================
  
  BattleHandlers::EOREffectItem.add(:FLAMEORB,
    proc { |item,battler,battle|
      next if !battler.pbCanBurn?(nil,false)
      battler.pbBurn(nil,_INTL("{1} was burned by the {2}!",battler.pbThis,battler.itemName))
    }
  )
  
  BattleHandlers::EOREffectItem.add(:STICKYBARB,
    proc { |item,battler,battle|
      next if !battler.takesIndirectDamage?
      oldHP = battler.hp
      battle.scene.pbDamageAnimation(battler)
      battler.pbReduceHP(battler.totalhp/8,false)
      battle.pbDisplay(_INTL("{1} is hurt by its {2}!",battler.pbThis,battler.itemName))
      battler.pbItemHPHealCheck
      battler.pbAbilitiesOnDamageTaken(oldHP)
      battler.pbFaint if battler.fainted?
    }
  )
  
  BattleHandlers::EOREffectItem.add(:TOXICORB,
    proc { |item,battler,battle|
      next if !battler.pbCanPoison?(nil,false)
      battler.pbPoison(nil,_INTL("{1} was badly poisoned by the {2}!",
         battler.pbThis,battler.itemName),true)
    }
  )
  
  #===============================================================================
  # CertainSwitchingUserItem handlers
  #===============================================================================
  
  BattleHandlers::CertainSwitchingUserItem.add(:SHEDSHELL,
    proc { |item,battler,battle|
      next true
    }
  )
  
  #===============================================================================
  # TrappingTargetItem handlers
  #===============================================================================
  
  # There aren't any!
  
  
  #===============================================================================
  # ItemOnSwitchIn handlers
  #===============================================================================
  
  BattleHandlers::ItemOnSwitchIn.add(:AIRBALLOON,
    proc { |item,battler,battle|
      battle.pbDisplay(_INTL("{1} floats in the air with its {2}!",
         battler.pbThis,battler.itemName))
    }
  )
  
  BattleHandlers::ItemOnSwitchIn.add(:ROOMSERVICE,
    proc { |item,battler,battle|
      next if battle.field.effects[PBEffects::TrickRoom] == 0
      next if !battler.pbCanLowerStatStage?(:SPEED,battler)
      battler.pbLowerStatStageByCause(:SPEED,1,battler,battler.itemName)
      if $fefieldeffect == 44
        battler.pbRecoverHP(battler.totalhp/3)
      end
      battler.pbConsumeItem
    }
  )
  
  #===============================================================================
  # ItemOnIntimidated handlers
  #===============================================================================
  
  BattleHandlers::ItemOnIntimidated.add(:ADRENALINEORB,
    proc { |item,battler,battle|
      next false if !battler.pbCanRaiseStatStage?(:SPEED,battler)
      itemName = GameData::Item.get(item).name
      battle.pbCommonAnimation("UseItem",battler)
      next battler.pbRaiseStatStageByCause(:SPEED,1,battler,itemName)
    }
  )
  
  #===============================================================================
  # RunFromBattleItem handlers
  #===============================================================================
  
  BattleHandlers::RunFromBattleItem.add(:SMOKEBALL,
    proc { |item,battler|
      next true
    }
  )
  
  #===============================================================================
  # ItemOnStatLoss handlers
  #===============================================================================
  
  BattleHandlers::ItemOnStatLoss.add(:EJECTPACK,
    proc { |item,battler,user,move,switched,battle|
      next if battle.pbAllFainted?(battler.idxOpposingSide)
      next if !battle.pbCanChooseNonActive?(battler.index)
        next if move.function=="0EE" # U-Turn, Volt-Switch, Flip Turn
        next if move.function=="151" # Parting Shot
      battle.pbCommonAnimation("UseItem",battler)
      battle.pbDisplay(_INTL("{1} is switched out with the {2}!",battler.pbThis,battler.itemName))
      battler.pbConsumeItem(true,false)
      newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
      next if newPkmn<0
      battle.pbRecallAndReplace(battler.index,newPkmn)
      battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
      switched.push(battler.index)
    }
  )
  