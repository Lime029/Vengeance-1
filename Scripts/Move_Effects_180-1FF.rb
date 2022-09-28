#===============================================================================
# User is protected against damaging moves this round. Decreases the Defense of
# the user of a stopped contact move by 2 stages. (Obstruct)
#===============================================================================
class PokeBattle_Move_180 < PokeBattle_ProtectMove
    def initialize(battle,move)
      super
      @effect = PBEffects::Obstruct
    end
  end
  
  
  
  #===============================================================================
  # Lowers target's Defense and Special Defense by 1 stage at the end of each
  # turn. Prevents target from retreating. (Octolock)
  #===============================================================================
  class PokeBattle_Move_181 < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      if target.effects[PBEffects::OctolockUser]>=0 || (target.damageState.substitute && !ignoresSubstitute?(user))
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if Settings::MORE_TYPE_EFFECTS && target.pbHasType?(:GHOST)
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.effects[PBEffects::OctolockUser] = user.index
      target.effects[PBEffects::Octolock] = true
      @battle.pbDisplay(_INTL("{1} can no longer escape!",target.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # Ignores move redirection from abilities and moves. (Snipe Shot)
  #===============================================================================
  class PokeBattle_Move_182 < PokeBattle_Move
  end
  
  
  
  #===============================================================================
  # Consumes berry and raises the user's Defense by 2 stages. (Stuff Cheeks)
  #===============================================================================
  class PokeBattle_Move_183 < PokeBattle_Move
  
    def pbMoveFailed?(user,targets)
      if (!user.item || !user.item.is_berry?) && user.pbCanRaiseStatStage?(:DEFENSE,user,self) &&
         $fefieldeffect != 15
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.pbRaiseStatStage(:DEFENSE,2,user)
      user.pbHeldItemTriggerCheck(user.item,false)
      user.pbConsumeItem(true,true,false) if user.item
    end
  end
  
  
  
  #===============================================================================
  # Forces all active Pokémon to consume their held berries. This move bypasses
  # Substitutes. (Teatime)
  #===============================================================================
  class PokeBattle_Move_184 < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbMoveFailed?(user,targets)
      @validTargets = []
      @battle.eachBattler do |b|
        next if !b.item || !b.item.is_berry?
        @validTargets.push(b.index)
      end
      if @validTargets.length==0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbFailsAgainstTarget?(user,target)
      return false if @validTargets.include?(target.index)
      return true if target.semiInvulnerable?
    end
  
    def pbEffectAgainstTarget(user,target)
      @battle.pbDisplay(_INTL("It's teatime! Everyone dug in to their Berries!"))
      target.pbHeldItemTriggerCheck(target.item,false)
      if target.item.is_berry?
        target.pbConsumeItem(true,true,false)
        if target.canHeal?
          target.pbRecoverHP(target.totalhp/2)
          @battle.pbDisplay(_INTL("{1}'s HP was restored!",target.pbThis))
        end
      end
    end
  end
  
  
  
  #===============================================================================
  # Decreases Opponent's Defense by 1 stage. Does Double Damage under gravity
  # (Grav Apple)
  #===============================================================================
  class PokeBattle_Move_185 < PokeBattle_TargetStatDownMove
    def getStatDown
      statDown = [:DEFENSE,1]
      return statDown
    end
  
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 1.5 if @battle.field.effects[PBEffects::Gravity] > 0 || @id == :GRAVAPPLE && 
                        $fefieldeffect == 15
      return baseDmg
    end
  end
  
  
  
  #===============================================================================
  # Decrease 1 stage of speed and weakens target to fire moves. (Tar Shot)
  #===============================================================================
  class PokeBattle_Move_186 < PokeBattle_Move
  
    def pbFailsAgainstTarget?(user,target)
      if !target.pbCanLowerStatStage?(:SPEED,target,self) && !target.effects[PBEffects::TarShot]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.pbLowerStatStage(:SPEED,1,target)
      target.effects[PBEffects::TarShot] = true
      @battle.pbDisplay(_INTL("{1} became weaker to fire!",target.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # Changes Category based on target's Defense and Sp. Def. Poisons the target.
  # (Shell Side Arm)
  #===============================================================================
  class PokeBattle_Move_187 < PokeBattle_Move_005
    def initialize(battle,move)
      super
      @calcCategory = 1
    end
  
    def pbContactMove?(user)
      ret = super
      ret = true if physicalMove?
      return ret
    end
  
    def physicalMove?(thisType=nil); return (@calcCategory==0); end
    def specialMove?(thisType=nil);  return (@calcCategory==1); end
      
    def setCalcCategory(c)
      @calcCategory = c
    end
  
    def pbOnStartUse(user,targets)
      return false if !targets.is_a?(Array)
      stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
      stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
      defense      = targets[0].defense
      defenseStage = targets[0].stages[:DEFENSE]+6
      realDefense  = (defense.to_f*stageMul[defenseStage]/stageDiv[defenseStage]).floor
      if $fefieldeffect == 24
        spdef        = [targets[0].spdef,targets[0].spatk].max
        spdefStage   = [targets[0].stages[:SPECIAL_DEFENSE],targets[0].stages[:SPECIAL_ATTACK]].max+6
      else
        spdef        = targets[0].spdef
        spdefStage   = targets[0].stages[:SPECIAL_DEFENSE]+6
      end
      realSpdef    = (spdef.to_f*stageMul[spdefStage]/stageDiv[spdefStage]).floor
      # Determine move's category
      @calcCategory = (realDefense < realSpdef) ? 0 : 1
    end
  end
  
  
  
  #===============================================================================
  # Hits 3 times and always critical. (Surging Strikes)
  #===============================================================================
  class PokeBattle_Move_188 < PokeBattle_Move_0A0
    def multiHitMove?;           return true; end
    def pbNumHits(user,targets); return 3;    end
  end
  
  #===============================================================================
  # Restore HP and heals any status conditions of itself and its allies
  # (Jungle Healing)
  #===============================================================================
  class PokeBattle_Move_189 < PokeBattle_Move
    def healingMove?; return true; end
  
    def pbMoveFailed?(user,targets)
      jglheal = 0
      for i in 0...targets.length
        jglheal += 1 if (!targets[i].canHeal?) && targets[i].pbHasAnyStatus?
      end
      if jglheal == targets.length
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbHealAmount(user,target)
      if $fefieldeffect == 47
        hpGain = (target.totalhp/2.0).round
      else
        hpGain = (target.totalhp/4.0).round
      end
      return hpGain
    end
    
    def pbEffectAgainstTarget(user,target)
      target.pbCureStatus
      if target.canHeal?
        target.pbRecoverHP(pbHealAmount(user,target))
        @battle.pbDisplay(_INTL("{1}'s health was restored.",target.pbThis))
      end
      super
    end
  end
  
  
  
  #===============================================================================
  # Changes type and base power based on Battle Terrain (Terrain Pulse)
  #===============================================================================
  class PokeBattle_Move_18A < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 2 if $fefieldeffect > 0
      return baseDmg
    end
  
    def pbBaseTypes(user)
      return [@battle.fieldType]
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      t = pbBaseTypes(user)
      hitNum = 1 if t == [:ELECTRIC]
      hitNum = 2 if t == [:GRASS]
      hitNum = 3 if t == [:FAIRY]
      hitNum = 4 if t == [:PSYCHIC]
      super
    end
  end
  
  
  
  #===============================================================================
  # Burns opposing Pokemon that have increased their stats in that turn before the
  # execution of this move (Burning Jealousy)
  #===============================================================================
  class PokeBattle_Move_18B < PokeBattle_Move
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      return if target.damageState.iceface
      if target.pbCanBurn?(user,false,self) && target.effects[PBEffects::BurningJealousy]
        target.pbBurn(user)
      end
    end
  end
  
  
  
  #===============================================================================
  # Move has increased Priority in Grassy Terrain (Grassy Glide)
  #===============================================================================
  class PokeBattle_Move_18C < PokeBattle_Move
    def pbChangePriority(user)
      return 1 if $fefieldeffect == 2 && user.grounded? || $fefieldeffect == 31 ||
                  $fefieldeffect == 33 && $fecounter >= 1
      return 0
    end
  end
  
  
  
  #===============================================================================
  # Power Doubles on Electric Terrain (Rising Voltage)
  #===============================================================================
  class PokeBattle_Move_18D < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 2 if [1,17,18].include?($fefieldeffect)
      return baseDmg
    end
  end
  
  
  
  #===============================================================================
  # Boosts allies' Attack and Defense (Coaching)
  #===============================================================================
  class PokeBattle_Move_18E < PokeBattle_Move
    def getStatUp
      statUp = [:ATTACK,1,:DEFENSE,1]
      if [6,20,45].include?($fefieldeffect)
        statUp = [:ATTACK,2,:DEFENSE,2]
      end
    end
    
    def pbMoveFailed?(user,targets)
      return false if damagingMove?
      failed = true
      noAllies = true
      user.eachAlly do |b|
        noAllies = false
        for i in 0...getStatUp.length/2
          next if !b.pbCanRaiseStatStage?(getStatUp[i*2],user,self)
          failed = false
          break
        end
        break if !failed
      end
      if noAllies
        @battle.pbDisplay(_INTL("But it failed!",user.pbThis))
        return true
      end
      if failed
        @battle.pbDisplay(_INTL("{1}'s allies' stats won't go any higher!",user.pbThis))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      return if damagingMove?
      showAnim = true
      user.eachAlly do |b|
        for i in 0...getStatUp.length/2
          next if !b.pbCanRaiseStatStage?(getStatUp[i*2],user,self)
          if b.pbRaiseStatStage(getStatUp[i*2],getStatUp[i*2+1],user,showAnim)
            showAnim = false
          end
        end
        if $fefieldeffect == 48
          b.effects[PBEffects::StrikeValue] = 15
          @battle.pbDisplay(_INTL("{1}'s advice prepares {2} to ride in a perfect wave!",user.pbThis,b.pbThis(true)))
        end
      end
    end
  
    def pbAdditionalEffect(user,target)
      showAnim = true
      user.eachAlly do |b|
        for i in 0...getStatUp.length/2
          next if !b.pbCanRaiseStatStage?(getStatUp[i*2],user,self)
          if b.pbRaiseStatStage(getStatUp[i*2],getStatUp[i*2+1],user,showAnim)
            showAnim = false
          end
        end
      end
    end
  end
  
  
  
  #===============================================================================
  # Renders item unusable (Corrosive Gas)
  #===============================================================================
  class PokeBattle_Move_18F < PokeBattle_Move
    def pbEffectAgainstTarget(user,target)
      return if @battle.wildBattle? && user.opposes?   # Wild Pokémon can't knock off
      return if user.fainted?
      return if target.damageState.substitute
      return if !target.item || target.unlosableItem?(target.item)
      return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
      itemName = target.itemName
      target.pbRemoveItem(false)
      @battle.pbDisplay(_INTL("{1}'s {2} was rendered unusable!",target.pbThis,itemName))
      if $fefieldeffect == 11 && !target.unstoppableAbility?
        target.effects[PBEffects::GastroAcid] = true
        target.effects[PBEffects::Truant]     = false
        @battle.pbDisplay(_INTL("{1}'s Ability was suppressed!",target.pbThis))
        target.pbOnAbilityChanged(target.ability)
      end
    end
  end
  
  
  
  #===============================================================================
  # Power increases x1.5 Psychic Terrain. Targets all near opposing Pokemon on
  # Psychic Terrain. (Expanding Force)
  #===============================================================================
  class PokeBattle_Move_190 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 1.5 if $fefieldeffect == 37
      return baseDmg
    end
  end
  
  
  
  #===============================================================================
  # Boosts Sp. Atk on first turn and attacks on the second (Meteor Beam)
  #===============================================================================
  class PokeBattle_Move_191 < PokeBattle_TwoTurnMove
    def pbIsChargingTurn?(user)
      ret = super
      if !user.effects[PBEffects::TwoTurnAttack]
        if $fefieldeffect == 34
          @powerHerb = false
          @chargingTurn = true
          @damagingTurn = true
        end
      end
      return ret
    end
    
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} is overflowing with space power!",user.pbThis))
    end
  
    def pbChargingTurnEffect(user,target)
      if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
        user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
      end
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      if @chargingTurn# && !@damagingTurn # Charging anim
        @battle.pbCommonAnimation("Meteor Beam charging",user)
        @chargingTurn = false
      else
        super
      end
    end
  end
  
  
  
  #===============================================================================
  # Fails if the Target has no Item (Poltergeist)
  #===============================================================================
  class PokeBattle_Move_192 < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      if !target.item && ![5,19].include?($fefieldeffect)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if $fefieldeffect == 5
        @battle.pbDisplay(_INTL("{1} is about to be attacked by a chess piece!",target.pbThis))
      elsif $fefieldeffect == 19
        @battle.pbDisplay(_INTL("{1} is about to be attacked by a piece of junk!",target.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} is about to be attacked by its {2}!",target.pbThis,target.itemName))
      end
      return false
    end
  end
  
  
  
  #===============================================================================
  # Reduces Defense and Raises Speed after all hits (Scale Shot)
  #===============================================================================
  class PokeBattle_Move_193 < PokeBattle_Move_0C0
    def pbEffectAfterAllHits(user,target)
      return if target.damageState.calcDamage == 0
      if user.pbCanRaiseStatStage?(:SPEED,user,self)
        user.pbRaiseStatStage(:SPEED,1,user)
      end
      if user.pbCanLowerStatStage?(:DEFENSE,target) && $fefieldeffect != 32
        user.pbLowerStatStage(:DEFENSE,1,user)
      end
    end
  end
  
  
  
  #===============================================================================
  # Double damage if stats were lowered that turn. (Lash Out)
  #===============================================================================
  class PokeBattle_Move_194 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 2 if user.effects[PBEffects::LashOut]
      return baseDmg
    end
  end
  
  
  
  #===============================================================================
  # Removes all Terrain. Fails if there is no Terrain (Steel Roller)
  #===============================================================================
  class PokeBattle_Move_195 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if $fefieldeffect == $febackup && ![4,14,25,30,44].include?($fefieldeffect)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      @battle.changeField($febackup,"The terrain returned to normal.") if ![4,14,25,30,44].include?($fefieldeffect)
    end
  end
  
  
  
  #===============================================================================
  # Self KO. Damage increases x1.5 when on Misty Terrain. (Misty Explosion)
  #===============================================================================
  class PokeBattle_Move_196 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 1.5 if $fefieldeffect == 3
      return baseDmg
    end
    
    def worksWithNoTargets?;     return true; end
    def pbNumHits(user,targets); return 1;    end
  
    def pbSelfKO(user)
      return if user.fainted? || [3,9,11].include?($fefieldeffect)
      user.pbReduceHP(user.hp,false,true,true,true)
      user.pbItemHPHealCheck
    end
    
    def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
      if $fefieldeffect == 6 && !user.fainted? && numHits > 0 && @battle.pbCanChooseNonActive?(user.index)
        @battle.pbDisplay(_INTL("{1} vanished in plain sight!",user.pbThis))
        @battle.pbPursuit(user.index)
        newPkmn = @battle.pbGetReplacementPokemonIndex(user.index)   # Owner chooses
        if newPkmn >= 0
          @battle.pbRecallAndReplace(user.index,newPkmn)
          @battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
          @battle.moldBreaker = false
          switchedBattlers.push(user.index)
          user.pbEffectsOnSwitchIn(true)
        end
      end
    end
  end
  
  
  
  #===============================================================================
  # Target becomes Psychic-type. (Magic Powder)
  #===============================================================================
  class PokeBattle_Move_197 < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      if !target.canChangeType? ||
         !target.pbHasOtherType?(:PSYCHIC)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      if $fefieldeffect == 40
        newType = :GHOST
      else
        newType = :PSYCHIC
      end
      target.pbChangeTypes(newType)
      typeName = GameData::Type.get(newType).name
      @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",target.pbThis,typeName))
      if $fefieldeffect == 37 && target.pbCanConfuse?(user,false)
        target.pbConfuse
      end
    end
  end
  
  #===============================================================================
  # Target's last move used loses 3 PP. (Eerie Spell)
  #===============================================================================
  class PokeBattle_Move_198 < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      failed = true
      target.eachMove do |m|
        next if m.id != target.lastRegularMoveUsed || m.pp==0 || m.total_pp<=0
        failed = false; break
      end
      if failed
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.eachMove do |m|
        next if m.id != target.lastRegularMoveUsed
        reduction = [3,m.pp].min
        target.pbSetPP(m,m.pp-reduction)
        @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",
           target.pbThis(true),m.name,reduction))
        break
      end
    end
  end
  
  
  #===============================================================================
  # Deals double damage to Mega Evolved Pokémon. (Behemoth Blade, Behemoth Bash, Dynamax Cannon)
  #===============================================================================
  class PokeBattle_Move_199 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      if target.mega?
        baseDmg *= 2
      end
      return baseDmg
    end
  end
  
  
  #===============================================================================
  # Badly poisons targets that are already poisoned, and boosts the status counter
  # by 1 for targets that are already badly poisoned. (Reactive Poison)
  #===============================================================================
  class PokeBattle_Move_19A < PokeBattle_Move
    def pbEffectAgainstTarget(user,target)
      if target.poisoned?
        if target.statusCount == 0
          @battle.pbCommonAnimation("Toxic", self)
          target.statusCount = 1
          @battle.pbDisplay(_INTL("{1} amplified {2}'s poisoning!",user.pbThis,target.pbThis(true)))
        elsif target.statusCount>0
          target.effects[PBEffects::Toxic] += 1
          @battle.pbDisplay(_INTL("{1} accelerated {2}'s poisoning!",user.pbThis,target.pbThis(true)))
        end
      end
    end
  end
  
  
  #===============================================================================
  # Hits X times, where X is the number of non-user unfainted status-free 
  # Dragon-type Pokémon in the user's party (not including partner trainers). 
  # Fails if X is 0. Base power of each hit depends on the base Attack stat for 
  # the species of that hit's participant. (Dragon Fleet)
  #===============================================================================
  class PokeBattle_Move_19B < PokeBattle_Move
    def multiHitMove?; return true; end
  
    def pbMoveFailed?(user,targets)
      @beatUpList = []
      @battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,i|
        next if !pkmn.able? || pkmn.status != :NONE || !(pkmn.hasType?(:DRAGON) || 
                i == user.pokemonIndex)
        @beatUpList.push(i)
      end
      if @beatUpList.length==0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbNumHits(user,targets)
      return @beatUpList.length
    end
  
    def pbBaseDamage(baseDmg,user,target)
      i = @beatUpList.shift   # First element in array, and removes it from array
      atk = @battle.pbParty(user.index)[i].baseStats[:ATTACK]
      return 5+(atk/5)
    end
  end
  
  
  #===============================================================================
  # Increases the user's Speed by 3 stages. Confuses user if any stat is raised.
  # (Overclock)
  #===============================================================================
  class PokeBattle_Move_19C < PokeBattle_StatUpMove
    def getStatUp
      statUp = [:SPEED,3]
      return statUp
    end
    
    def pbEffectGeneral(user)
      return if damagingMove?
      if user.hasRaisedStatStages?
        user.pbConfuse if user.pbCanConfuseSelf?(true) && $fefieldeffect != 17
      end
      return super
    end
  
    def pbAdditionalEffect(user,target)
      if user.hasRaisedStatStages?
        user.pbConfuse if user.pbCanConfuseSelf?(true) && $fefieldeffect != 17
      end
      return super
    end
  end
  
  
  #===============================================================================
  # Increases the user's Special Defense and Evasion by 1 stage each. (Mist Guard)
  #===============================================================================
  class PokeBattle_Move_19D < PokeBattle_StatUpMove
    def getStatUp
      statUp = [:SPECIAL_DEFENSE,1,:EVASION,1]
      if [3,9,11].include?($fefieldeffect)
        statUp = [:SPECIAL_DEFENSE,2,:EVASION,2]
      end
      return statUp
    end
  end
  
  
  #===============================================================================
  # User must use this move for 4 more rounds. Power doubles each round. (Eternal Flame)
  #===============================================================================
  class PokeBattle_Move_19E < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      shift = (5 - user.effects[PBEffects::Rollout])   # 0-4, where 0 is most powerful
      shift = 0 if user.effects[PBEffects::Rollout] == 0   # For first turn
      baseDmg *= 2**shift
      return baseDmg
    end
  
    def pbEffectAfterAllHits(user,target)
      if !target.damageState.unaffected && user.effects[PBEffects::Rollout] == 0
        user.effects[PBEffects::Rollout] = 5
        user.currentMove = @id
      end
      user.effects[PBEffects::Rollout] -= 1 if user.effects[PBEffects::Rollout] > 0
    end
  end
  
  
  #===============================================================================
  # Decreases the target's Accuracy by 1 stage. Accuracy perfect in sandstorm. (Dust Storm)
  #===============================================================================
  class PokeBattle_Move_19F < PokeBattle_Move_047 # Accuracy down
    def pbBaseAccuracy(user,target,types=@calcTypes)
      return 0 if @battle.pbWeather == :Sandstorm || [12,49].include?($fefieldeffect)
      return super
    end
  end
  
  
  #===============================================================================
  # User must use this move until it misses. Power doubles each round. (Infinite Force)
  #===============================================================================
  class PokeBattle_Move_1A0 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      shift = user.effects[PBEffects::Rollout]
      baseDmg *= 2**shift
      return baseDmg
    end
  
    def pbEffectAfterAllHits(user,target)
      if !target.damageState.unaffected && user.effects[PBEffects::Rollout] == 0
        user.currentMove = @id
      end
      user.effects[PBEffects::Rollout] += 1
    end
  end
  
  
  #===============================================================================
  # Power is chosen at random. Power is doubled if the target is using Dive. Hits
  # some semi-invulnerable targets. (Tsunami)
  #===============================================================================
  class PokeBattle_Move_1A1 < PokeBattle_Move
    def hitsDivingTargets?; return true; end
    
    def pbOnStartUse(user,targets)
      baseDmg = [10,30,50,70,90,110,150]
      magnitudes = [
         4,
         5,5,
         6,6,6,6,
         7,7,7,7,7,7,
         8,8,8,8,
         9,9,
         10
      ]
      magni = magnitudes[@battle.pbRandom(magnitudes.length)]
      @magnitudeDmg = baseDmg[magni-4]
      @battle.pbDisplay(_INTL("Intensity {1}!",magni))
    end
  
    def pbBaseDamage(baseDmg,user,target)
      return @magnitudeDmg
    end
    
    def pbModifyDamage(damageMult,user,target)
      damageMult *= 2 if target.inTwoTurnAttack?("0CB")   # Dive
      return damageMult
    end
  end
  
  
  #===============================================================================
  # Hits X times, where X is the number of non-user unfainted status-free Pokémon
  # in the user's party (not including partner trainers). Fails if X is 0.
  # Base power of each hit depends on the base Sp. Atk stat for the species of 
  # that hit's participant. (Chain Lightning)
  #===============================================================================
  class PokeBattle_Move_1A2 < PokeBattle_Move
    def multiHitMove?; return true; end
  
    def pbMoveFailed?(user,targets)
      @beatUpList = []
      @battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,i|
        next if !pkmn.able? || pkmn.status != :NONE
        @beatUpList.push(i)
      end
      if @beatUpList.length==0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbNumHits(user,targets)
      return @beatUpList.length
    end
  
    def pbBaseDamage(baseDmg,user,target)
      i = @beatUpList.shift   # First element in array, and removes it from array
      atk = @battle.pbParty(user.index)[i].baseStats[:SPECIAL_ATTACK]
      return 5+(atk/10)
    end
  end
  
  
  #===============================================================================
  # Decreases the target's Special Defense by 1 stage. May cause the target to 
  # flinch. (Ferocious Bellow)
  #===============================================================================
  class PokeBattle_Move_1A3 < PokeBattle_Move
    def flinchingMove?; return true; end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      chance = pbAdditionalEffectChance(user,target,20)
      return if chance==0
      if @battle.pbRandom(100)<chance
        if target.hasShieldDust? && !@battle.moldBreaker
          if $fefieldeffect == 19
            user.pbCheckAndInflictRandomStatus(target)
          end
        else
          target.pbLowerStatStage(:SPECIAL_DEFENSE,1,user)
        end
      end
      chance = pbAdditionalEffectChance(user,target,20)
      if @battle.pbRandom(100)<chance
        if target.hasShieldDust? && !@battle.moldBreaker
          if $fefieldeffect == 19
            user.pbCheckAndInflictRandomStatus(target)
          end
        else
          target.pbFlinch(user)
        end
      end
    end
  end
  
  
  #===============================================================================
  # Poisons, puts to sleep or flinches the target. (Crisis Vine)
  #===============================================================================
  class PokeBattle_Move_1A4 < PokeBattle_Move
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      case rand(3)
      when 0 then target.pbPoison(user) if target.pbCanPoison?(user,false,self)
      when 1 then target.pbSleep if target.pbCanSleep?(user,false,self)
      when 2 then target.pbFlinch(user)
      end
    end
  end
  
  
  #===============================================================================
  # Poisons the target. Power is doubled if the target has a status problem. 
  # (Barb Barrage)
  #===============================================================================
  class PokeBattle_Move_1A5 < PokeBattle_PoisonMove
    def pbBaseDamage(baseDmg,user,target)
      if target.pbHasAnyStatus? && (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
        baseDmg *= 2
      end
      return baseDmg
    end
    
    def pbEffectAfterAllHits(user,target)
      user.pokemon.barb_barrage_uses += 1
    end
  end
  
  
  #===============================================================================
  # Freezes the target. Power is doubled if the target has a status problem. 
  # (Bitter Malice)
  #===============================================================================
  class PokeBattle_Move_1A6 < PokeBattle_FreezeMove
    def pbBaseDamage(baseDmg,user,target)
      if target.pbHasAnyStatus? && (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
        baseDmg *= 2
      end
      return baseDmg
    end
  end
  
  
  #===============================================================================
  # Leaves splinters behind that continue to damage the target for 5 turns.
  # (Ceaseless Edge)
  #===============================================================================
  class PokeBattle_Move_1A7 < PokeBattle_Move
    def pbEffectAgainstTarget(user,target)
      return if target.fainted? || target.damageState.substitute
      return if target.effects[PBEffects::Splinter]>0
      target.effects[PBEffects::Splinter] = 5
      @battle.pbDisplay(_INTL("Splinters planted themselves in {1}!",target.pbThis(true)))
    end
  end
  
  
  #===============================================================================
  # Damages user by 1/2 of its max HP, even if this move misses. Decreases the 
  # user's Speed by 1 stage. (Chloroblast)
  #===============================================================================
  class PokeBattle_Move_1A8 < PokeBattle_Move
    def worksWithNoTargets?; return true; end
  
    def pbSelfKO(user)
      return if !user.takesIndirectDamage?
      user.pbReduceHP((user.totalhp/2.0).round,false)
      user.pbItemHPHealCheck
    end
    
    def pbEffectWhenDealingDamage(user,target)
      return if @battle.pbAllFainted?(target.idxOwnSide) || [2,15,47].include?($fefieldeffect) ||
                $fefieldeffect == 33 && $fecounter > 0
      user.pbLowerStatStage(:SPEED,1,user)
    end
  end
  
  
  #===============================================================================
  # Poisons, puts to sleep or paralyzes the target. (Dire Claw)
  #===============================================================================
  class PokeBattle_Move_1A9 < PokeBattle_Move
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      case rand(3)
      when 0 then target.pbPoison(user) if target.pbCanPoison?(user, false, self)
      when 1 then target.pbSleep if target.pbCanSleep?(user, false, self)
      when 2 then target.pbParalyze(user) if target.pbCanParalyze?(user, false, self)
      end
    end
  end
  
  
  #===============================================================================
  # Burns the target. Power is doubled if the target has a status problem. 
  # (Infernal Parade)
  #===============================================================================
  class PokeBattle_Move_1AA < PokeBattle_BurnMove
    def pbBaseDamage(baseDmg,user,target)
      if target.pbHasAnyStatus? && (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
        baseDmg *= 2
      end
      return baseDmg
    end
  end
  
  
  #===============================================================================
  # Heals user by 1/2 of its max HP. Cures user of non-volatile status conditions.
  # Increases the user's evasion by 1 stage. (Lunar Blessing)
  #===============================================================================
  class PokeBattle_Move_1AB < PokeBattle_Move
    def healingMove?
      return true
    end
    
    def pbHealAmount(user)
      return (user.totalhp/2.0).round
    end
    
    def pbMoveFailed?(user,targets)
      if !user.pbCanRaiseStatStage?(:EVASION,user,self,false) && user.hp==user.totalhp &&
         !user.pbHasAnyStatus?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      if user.pbRecoverHP(pbHealAmount(user)) > 0
        @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
      end
      user.pbRaiseStatStage(:EVASION,1,user)
      user.pbCureStatus
    end
  end
  
  
  #===============================================================================
  # Increases the user's highest stat between Attack, Defense, Sp. Atk, and Sp.
  # Def by 1 stage. (Mystical Power)
  #===============================================================================
  class PokeBattle_Move_1AC < PokeBattle_Move
    def pbAdditionalEffect(user,target)
      highest = :ATTACK
      highestNum = user.attack
      if user.defense > highestNum
        highest = :DEFENSE
        highestNum = user.defense
      end
      if user.spatk > highestNum
        highest = :SPECIAL_ATTACK
        highestNum = user.spatk
      end
      if user.spdef > highestNum
        highest = :SPECIAL_DEFENSE
        highestNum = user.spdef
      end
      user.pbRaiseStatStage(highest,1,user)
    end
  end
  
  
  #===============================================================================
  # Swaps the user's Attack and Defense stats with its Sp. Atk and Sp. Def stats,
  # respectively. (Power Shift)
  #===============================================================================
  class PokeBattle_Move_1AD < PokeBattle_Move
    def pbEffectGeneral(user)
      user.attack,user.defense = user.defense,user.attack
      user.spatk,user.spdef = user.spdef,user.spatk
      user.effects[PBEffects::PowerShift] = !user.effects[PBEffects::PowerShift]
      @battle.pbDisplay(_INTL("{1} switched its Attack with Defense and Sp. Atk with Sp. Def!",user.pbThis))
    end
  end
  
  
  #===============================================================================
  # Increases the user's Defense, Sp. Def, and Evasion by 1 stage. (Shelter)
  #===============================================================================
  class PokeBattle_Move_1AE < PokeBattle_StatUpMove
    def getStatUp
      statUp = [:DEFENSE,1,:SPECIAL_DEFENSE,1,:EVASION,1]
      return statUp
    end
  end
  
  
  #===============================================================================
  # If the user is in its base form, increases its Attack, Defense, Speed, Special
  # Attack, and Special Defense by 1 stage each. If the user is in any other form,
  # decreases the target's Defense and Special Defense by 1 stage each.
  # (Springtide Storm)
  #===============================================================================
  class PokeBattle_Move_1AF < PokeBattle_Move
    def pbAdditionalEffect(user,target)
      if user.form == 0
        user.pbRaiseStatStage([:ATTACK,:DEFENSE,:SPEED,:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,user)
      elsif !target.damageState.substitute
        target.pbLowerStatStage([:DEFENSE,:SPECIAL_DEFENSE],1,user)
      end
    end
  end
  
  
  #===============================================================================
  # Cures user of non-volatile status conditions. Increases the user's Attack,
  # Sp. Atk, Defense, and Sp. Def by 1 stage. (Take Heart)
  #===============================================================================
  class PokeBattle_Move_1B0 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      failed = true
      for stat in [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE]
        next if !user.pbCanRaiseStatStage?(stat,user,self)
        failed = false
        break
      end
      if failed && !user.pbHasAnyStatus?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.pbRaiseStatStage([:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE],1,user)
      user.pbCureStatus
    end
  end
  
  
  #===============================================================================
  # Increases the user's critical hit rate by 1 stage. Decreases the target's
  # Defense and Special Defense by 1 stage. (Triple Arrows)
  #===============================================================================
  class PokeBattle_Move_1B1 < PokeBattle_Move
    def pbAdditionalEffect(user,target)
      user.pbRaiseCritRatio(1,user)
      return if target.damageState.substitute
      target.pbLowerStatStage([:DEFENSE,:SPECIAL_DEFENSE],1,user)
    end
  end
  
  
  #===============================================================================
  # Increases the user's Attack and Defense by 1 stage. Increases the user's
  # damage dealt by 50% until it switches out. (Victory Dance)
  #===============================================================================
  class PokeBattle_Move_1B2 < PokeBattle_Move_024 # Bulk Up
    def pbMoveFailed?(user,targets)
      failed = true
      for stat in [:ATTACK,:DEFENSE]
        next if !user.pbCanRaiseStatStage?(stat,user,self)
        failed = false
        break
      end
      if failed && user.effects[PBEffects::VictoryDance]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      super
      if !user.effects[PBEffects::VictoryDance]
        user.effects[PBEffects::VictoryDance] = true
        @battle.pbDisplay(_INTL("{1} was hyped up by its victory dance!",user.pbThis))
      end
    end
  end
  
  
  #===============================================================================
  # Increases the user's Speed by 1 stage. User takes recoil damage equal to 1/3
  # of the damage this move dealt. (Wave Crash)
  #===============================================================================
  class PokeBattle_Move_1B3 < PokeBattle_Move_01F # Child of Speed up move
    def recoilMove?
      return true
    end
    
    def pbRecoilDamage(user,target)
      return (target.damageState.totalHPLost/3.0).round
    end
  
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
  
  
  
  # NOTE: If you're inventing new move effects, use function code 199 and onwards.
  #       Actually, you might as well use high numbers like 500+ (up to FFFF),
  #       just to make sure later additions to Essentials don't clash with your
  #       new effects.
  