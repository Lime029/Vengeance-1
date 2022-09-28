class PokeBattle_Battler
    #=============================================================================
    # Increase stat stages
    #=============================================================================
    def statStageAtMax?(stat)
      return @stages[stat]>=6
    end
  
    def pbCanRaiseStatStage?(stat,user=nil,move=nil,showFailMsg=false,ignoreContrary=false)
      return false if fainted?
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
        return pbCanLowerStatStage?(stat,user,move,showFailMsg,true)
      end
      # Check the stat stage
      if statStageAtMax?(stat)
        @battle.pbDisplay(_INTL("{1}'s {2} won't go any higher!",
           pbThis, GameData::Stat.get(stat).name)) if showFailMsg
        return false
      end
      return true
    end
  
    def pbRaiseStatStageBasic(stat,increment,ignoreContrary=false)
      if !@battle.moldBreaker
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary
          increment *= 2 if $fefieldeffect == 36
          return pbLowerStatStageBasic(stat,increment,true)
        end
        # Simple
        if hasActiveAbility?(:SIMPLE) && ![17,18].include?($fefieldeffect)
          if $fefieldeffect == 44
            increment *= 3
          else
            increment *= 2
          end
        end
      end
      # Change the stat stage
      increment = [increment,6-@stages[stat]].min
      if increment>0
        stat_name = GameData::Stat.get(stat).name
        new = @stages[stat]+increment
        PBDebug.log("[Stat change] #{pbThis}'s #{stat_name}: #{@stages[stat]} -> #{new} (+#{increment})")
        @stages[stat] += increment
      end
      return increment
    end
    
    def pbRaiseStatStage(stat,increment,user=nil,showAnim=true,ignoreContrary=false)
      # Balanced Charges
      if !user.nil? && user.hasActiveAbility?(:BALANCEDCHARGES)
        # Share based on as if the move targeted all allies of the target instead of inflicting same stat change target gets
        if user.pokemon.baseStats[:SPECIAL_ATTACK] > user.pokemon.baseStats[:SPECIAL_DEFENSE] # Plusle
          eachAlly do |b| # Recipient's allies
            @battle.pbDisplay(_INTL("{1}'s {2} shared the stat changes with {3}!",user.pbThis,user.abilityName,b.pbThis(true)))
            b.pbRaiseStatStage(stat,increment) # No user to prevent infinite loop
          end
        end
      end
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
        return pbLowerStatStage(stat,increment,user,showAnim,true)
      end
      if !stat.is_a?(Array)
        stat = [stat]
      end
      # Factory Attack scale
      if $fefieldeffect == 17
        for s in stat
          if s == :SPEED
            stat.push(:ATTACK)
            break
          end
        end
      end
      # Luminous Scales
      if hasActiveAbility?(:LUMINOUSSCALES) && !([8,21,26].include?($fefieldeffect) && 
         grounded?) && $fefieldeffect != 22
        maxLen = stat.length # set beforehand so it's not changing as loop progresses
        for i in 0...maxLen
          if stat[i] == :ATTACK
            stat.push(:SPECIAL_ATTACK)
          elsif stat[i] == :DEFENSE
            stat.push(:SPECIAL_DEFENSE)
          elsif stat[i] == :SPECIAL_ATTACK
            stat.push(:ATTACK)
          elsif stat[i] == :SPECIAL_DEFENSE
            stat.push(:DEFENSE)
          end
        end
      end
      # Fairy Tale Field - Rogue
      if $fefieldeffect == 31 && @effects[PBEffects::FairyTaleRoles].include?(8)
        for s in stat
          if s == :EVASION
            if rand(2) == 0
              stat.push(:ATTACK)
              @battle.pbDisplay(_INTL("{1}'s Rogue role scaled its Evasion change with its Attack!",pbThis))
            else
              stat.push(:SPEED)
              @battle.pbDisplay(_INTL("{1}'s Rogue role scaled its Evasion change with its Speed!",pbThis))
            end
            break
          end
        end
      end
      arrOneStage=[]
      arrTwoStage=[]
      arrThreeStage=[]
      worked=false
      for s in stat
        next if !pbCanRaiseStatStage?(s,user)
        incrementTemp=pbRaiseStatStageBasic(s,increment,ignoreContrary)
        if incrementTemp>0
          showAnim = false if worked
          @battle.pbCommonAnimation("StatUp",self) if showAnim
          case incrementTemp
          when 1
            arrOneStage.push(GameData::Stat.get(s).name)
          when 2
            arrTwoStage.push(GameData::Stat.get(s).name)
          else
            arrThreeStage.push(GameData::Stat.get(s).name)
          end
          # Trigger abilities upon stat gain
          if abilityActive?
            #BattleHandlers.triggerAbilityOnStatGain(self.ability,self,stat,user)
          end
          worked=true
        end
      end
      if worked
        texts = []
        for arr in [arrOneStage,arrTwoStage,arrThreeStage]
          if arr.length == 1
            texts.push(arr[0])
          elsif arr.length == 2
            texts.push(arr[0]+" and "+arr[1])
          else # if arr.length > 2
            temp = ""
            for i in 0...arr.length
              temp+=arr[i]
              if i == arr.length-2
                temp+=", and "
              elsif i != arr.length-1
                temp+=", "
              end
            end
            texts.push(temp)
          end
        end
        if texts[0] != ""
          @battle.pbDisplay(_INTL("{1}'s {2} rose!",pbThis,texts[0]))
        end
        if texts[1] != ""
          @battle.pbDisplay(_INTL("{1}'s {2} rose sharply!",pbThis,texts[1]))
        end
        if texts[2] != ""
          @battle.pbDisplay(_INTL("{1}'s {2} rose drastically!",pbThis,texts[2]))
        end
        @effects[PBEffects::BurningJealousy] = true
      end
      if $fefieldeffect == 31 && !@effects[PBEffects::FairyTaleRoles].include?(8) &&
         stat.include?(:EVASION)
        @effects[PBEffects::FairyTaleRoles].push(8)
        @battle.pbDisplay(_INTL("{1} was given the Rogue role!",pbThis))
      end
      return worked
    end
  
    def pbRaiseStatStageByCause(stat,increment,user,cause,showAnim=true,showMessages=true,ignoreContrary=false)
      # Balanced Charges
      if !user.nil? && user.hasActiveAbility?(:BALANCEDCHARGES)
        # Share based on as if the move targeted all allies of the target instead of inflicting same stat change target gets
        if user.pokemon.baseStats[:SPECIAL_ATTACK] > user.pokemon.baseStats[:SPECIAL_DEFENSE] # Plusle
          eachAlly do |b| # Recipient's allies
            @battle.pbDisplay(_INTL("{1}'s {2} shared the stat changes with {3}!",user.pbThis,user.abilityName,b.pbThis(true)))
            b.pbRaiseStatStage(stat,increment) # No user to prevent infinite loop
          end
        end
      end
      showMessages=false if cause.nil?
      # Contrary
      if hasActiveAbility?(:CONTRARY) && !ignoreContrary && !@battle.moldBreaker
        return pbLowerStatStageByCause(stat,increment,user,cause,showAnim,showMessages,true)
      end
      if !stat.is_a?(Array)
        stat = [stat]
      end
      # Factory Attack scale
      if $fefieldeffect == 17
        for s in stat
          if s == :SPEED
            stat.push(:ATTACK)
            break
          end
        end
      end
      # Luminous Scales
      if hasActiveAbility?(:LUMINOUSSCALES) && !([8,21,26].include?($fefieldeffect) && 
         grounded?) && $fefieldeffect != 22
        maxLen = stat.length # set beforehand so it's not changing as loop progresses
        for i in 0...maxLen
          if stat[i] == :ATTACK
            stat.push(:SPECIAL_ATTACK)
          elsif stat[i] == :DEFENSE
            stat.push(:SPECIAL_DEFENSE)
          elsif stat[i] == :SPECIAL_ATTACK
            stat.push(:ATTACK)
          elsif stat[i] == :SPECIAL_DEFENSE
            stat.push(:DEFENSE)
          end
        end
      end
      # Fairy Tale Field - Rogue
      if $fefieldeffect == 31 && @effects[PBEffects::FairyTaleRoles].include?(8)
        for s in stat
          if s == :EVASION
            if rand(2) == 0
              stat.push(:ATTACK)
              @battle.pbDisplay(_INTL("{1}'s Rogue role scaled its Evasion change with its Attack!"))
            else
              stat.push(:SPEED)
              @battle.pbDisplay(_INTL("{1}'s Rogue role scaled its Evasion change with its Speed!"))
            end
            break
          end
        end
      end
      arrOneStage=[]
      arrTwoStage=[]
      arrThreeStage=[]
      worked=false
      for s in stat
        next if !pbCanRaiseStatStage?(s,user)
        incrementTemp=pbRaiseStatStageBasic(s,increment,ignoreContrary)
        if incrementTemp>0
          showAnim = false if worked
          @battle.pbCommonAnimation("StatUp",self) if showAnim
          case incrementTemp
          when 1
            arrOneStage.push(GameData::Stat.get(s).name)
          when 2
            arrTwoStage.push(GameData::Stat.get(s).name)
          else
            arrThreeStage.push(GameData::Stat.get(s).name)
          end
          # Trigger abilities upon stat gain
          if abilityActive?
            #BattleHandlers.triggerAbilityOnStatGain(self.ability,self,stat,user)
          end
          worked=true
        end
      end
      if worked && showMessages
        texts = []
        for arr in [arrOneStage,arrTwoStage,arrThreeStage]
          if arr.length == 1
            texts.push(arr[0])
          elsif arr.length == 2
            texts.push(arr[0]+" and "+arr[1])
          else # if arr.length > 2
            temp = ""
            for i in 0...arr.length
              temp+=arr[i]
              if i == arr.length-2
                temp+=", and "
              elsif i != arr.length-1
                temp+=", "
              end
            end
            texts.push(temp)
          end
        end
        if user.nil? || user.index==self.index
          if texts[0] != ""
            @battle.pbDisplay(_INTL("{1}'s {2} raised its {3}!",pbThis,cause,texts[0]))
          end
          if texts[1] != ""
            @battle.pbDisplay(_INTL("{1}'s {2} sharply raised its {3}!",pbThis,cause,texts[1]))
          end
          if texts[2] != ""
            @battle.pbDisplay(_INTL("{1}'s {2} drastically raised its {3}!",pbThis,cause,texts[2]))
          end
        else
          if texts[0] != ""
            @battle.pbDisplay(_INTL("{1}'s {2} raised {3}'s {4}!",user.pbThis,cause,pbThis(true),texts[0]))
          end
          if texts[1] != ""
            @battle.pbDisplay(_INTL("{1}'s {2} sharply raised {3}'s {4}!",user.pbThis,cause,pbThis(true),texts[1]))
          end
          if texts[2] != ""
            @battle.pbDisplay(_INTL("{1}'s {2} drastically raised {3}'s {4}!",user.pbThis,cause,pbThis(true),texts[2]))
          end
        end
        @effects[PBEffects::BurningJealousy] = true
      end
      if $fefieldeffect == 31 && !@effects[PBEffects::FairyTaleRoles].include?(8) &&
         stat.include?(:EVASION)
        @effects[PBEffects::FairyTaleRoles].push(8)
        @battle.pbDisplay(_INTL("{1} was given the Rogue role!",pbThis))
      end
      return worked
    end
    
    def pbRaiseStatStageByAbility(stat,increment,user,splashAnim=true)
      return false if fainted?
      ret = pbRaiseStatStageByCause(stat,increment,user,user.abilityName)
      return ret
    end
  
    #=============================================================================
    # Decrease stat stages
    #=============================================================================
    def statStageAtMin?(stat)
      return @stages[stat]<=-6
    end
    
    def statLossImmunityByAbility?(stat,showMessages)
      if hasActiveAbility?(:FULLMETALBODY) && !($fefieldeffect == 10 && grounded?)
        if showMessages
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",pbThis))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",pbThis,abilityName))
          end
        end
        return true
      end
      return false if @battle.moldBreaker
      if hasActiveAbility?(:CLEARBODY) || hasActiveAbility?(:WHITESMOKE) && ![22,39].include?($fefieldeffect) || 
         hasActiveAbility?(:FLOWERVEIL) && (pbHasType?(:GRASS) || [2,15,31,42,47].include?($fefieldeffect) ||
         $fefieldeffect == 33 && $fecounter >= 3) && ![7,10,11,16,41].include?($fefieldeffect) || 
         hasActiveAbility?(:INNERFOCUS) && $fefieldeffect == 5 || hasActiveAbility?(:ZENMODE) && 
         $fefieldeffect == 20
        if showMessages
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",pbThis))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",pbThis,abilityName))
          end
        end
        return true
      end
      return false
    end
    
    def statLossFullImmunityByAbility?(stat,showMessages)
      if stat == :ATTACK && hasActiveAbility?(:HYPERCUTTER)
        if showMessages
          @battle.pbShowAbilitySplash(self)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",pbThis,GameData::Stat.get(stat).name))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",pbThis,abilityName,GameData::Stat.get(stat).name))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return true
      end
      if stat == :DEFENSE && hasActiveAbility?(:BIGPECKS)
        if showMessages
          @battle.pbShowAbilitySplash(self)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",pbThis,GameData::Stat.get(stat).name))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",pbThis,abilityName,GameData::Stat.get(stat).name))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return true
      end
      if stat == :ACCURACY
        if hasActiveAbility?(:KEENEYE) || hasActiveAbility?(:OWNTEMPO) && $fefieldeffect == 30 || 
           hasActiveAbility?(:INNERFOCUS) && $fefieldeffect == 6
          if showMessages
            @battle.pbShowAbilitySplash(self)
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              @battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",pbThis,GameData::Stat.get(stat).name))
            else
              @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",pbThis,abilityName,GameData::Stat.get(stat).name))
            end
            @battle.pbHideAbilitySplash(self)
          end
          return true
        elsif hasActiveItem?(:SAFETYGOGGLES)
          if showMessages
            @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",pbThis,itemName,GameData::Stat.get(stat).name))
          end
          return true
        end
      end
      if stat == :SPECIAL_ATTACK && hasActiveAbility?(:EMPYREAN)
        if showMessages
          @battle.pbShowAbilitySplash(self)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",pbThis,GameData::Stat.get(stat).name))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",pbThis,abilityName,GameData::Stat.get(stat).name))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return true
      end
      if stat == :SPECIAL_DEFENSE && hasActiveAbility?(:DIVINE) && ![38,40,42].include?($fefieldeffect)
        if showMessages
          @battle.pbShowAbilitySplash(self)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",pbThis,GameData::Stat.get(stat).name))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",pbThis,abilityName,GameData::Stat.get(stat).name))
          end
          @battle.pbHideAbilitySplash(self)
        end
        return true
      end
      if hasActiveAbility?(:WHITESMOKE) && [7,16].include?($fefieldeffect)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",pbThis,abilityName)) if showMessages
        return true
      end
      if $fefieldeffect == 34 && [:MILD,:BASHFUL].include?(@pokemon.nature_id)
        @battle.pbDisplay(_INTL("{1}'s astrological sign (Libra) prevents stat loss!",pbThis)) if showMessages
        return true
      end
      return false
    end
    
    def statLossImmunityByAllyAbility?(ally,stat,showMessages)
      if ally.hasActiveAbility?(:FLOWERVEIL) && (pbHasType?(:GRASS) || [2,15,31,42,47].include?($fefieldeffect) ||
         $fefieldeffect == 33 && $fecounter >= 3) && ![7,10,11,16,41].include?($fefieldeffect)
        if showMessages
          @battle.pbShowAbilitySplash(ally)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",pbThis))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s stat loss!",ally.pbThis,ally.abilityName,pbThis(true)))
          end
          @battle.pbHideAbilitySplash(ally)
        end
        return true
      end
      return false
    end
  
    def pbCanLowerStatStage?(stat,user=nil,move=nil,showFailMsg=false,ignoreContrary=false)
      return false if fainted?
      if !@battle.moldBreaker
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary
          return pbCanRaiseStatStage?(stat,user,move,showFailMsg,true)
        end
        return false if statLossFullImmunityByAbility?(stat,showFailMsg)
      end
      if [3,11].include?($fefieldeffect) && pbOwnSide.effects[PBEffects::Mist]>0 && 
         !(user && user.hasActiveAbility?(:INFILTRATOR))
        @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis)) if showFailMsg
        return false
      end
      if !user || user.index!=@index   # Not self-Inflicted
        if @effects[PBEffects::Substitute]>0 && !(move && move.ignoresSubstitute?(user))
          @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis)) if showFailMsg
          return false
        end
        if pbOwnSide.effects[PBEffects::Mist]>0 && !(user && (user.hasActiveAbility?(:INFILTRATOR) ||
           user.hasActiveAbility?(:UNSEENFIST) && [34,38].include?($fefieldeffect)))
          @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis)) if showFailMsg
          return false
        end
        return false if statLossImmunityByAbility?(stat,showFailMsg)
        #return false if BattleHandlers.triggerStatLossImmunityAbility(self.ability,self,stat,@battle,showFailMsg) if !@battle.moldBreaker
        #return false if BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(self.ability,self,stat,@battle,showFailMsg)
        if !@battle.moldBreaker
          eachAlly do |b|
            next if !b.abilityActive?
            #return false if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability,b,self,stat,@battle,showFailMsg)
            return false if statLossImmunityByAllyAbility?(b,stat,showFailMsg)
          end
        end
      else # Self-Inflicted
        if hasActiveAbility?(:UNEXTINGUISHABLE) && (@hp < @totalhp/2 || [7,16,31].include?($fefieldeffect)) &&
           !([21,26].include?($fefieldeffect) && grounded?) && $fefieldeffect != 22
          @battle.pbDisplay(_INTL("{1}'s {2} prevents self-inflicted stat loss!",pbThis,abilityName)) if showFailMsg
          return false
        end
      end
      # Check the stat stage
      if statStageAtMin?(stat)
        @battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!",
           pbThis, GameData::Stat.get(stat).name)) if showFailMsg
        return false
      end
      return true
    end
    
    def abilityOnStatLoss(user)
      return if user && !user.opposes?(self)
      if hasActiveAbility?(:COMPETITIVE) && $fefieldeffect != 20
        if $fefieldeffect == 45
          pbRaiseStatStageByAbility(:ATTACK,3,self)
        else
          pbRaiseStatStageByAbility(:SPECIAL_ATTACK,2,self)
        end
      end
      if hasActiveAbility?(:DEFIANT)
        pbRaiseStatStageByAbility(:ATTACK,2,self)
      end
    end
  
    def pbLowerStatStageBasic(stat,increment,ignoreContrary=false)
      if !@battle.moldBreaker
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary
          increment *= 2 if $fefieldeffect == 36
          return pbRaiseStatStageBasic(stat,increment,true)
        end
        # Simple
        if hasActiveAbility?(:SIMPLE) && ![17,18].include?($fefieldeffect)
          if $fefieldeffect == 44
            increment *= 3
          else
            increment *= 2
          end
        end
      end
      # Change the stat stage
      increment = [increment,6+@stages[stat]].min
      if increment>0
        stat_name = GameData::Stat.get(stat).name
        new = @stages[stat]-increment
        PBDebug.log("[Stat change] #{pbThis}'s #{stat_name}: #{@stages[stat]} -> #{new} (-#{increment})")
        @stages[stat] -= increment
      end
      return increment
    end
    
    def pbLowerStatStage(stat,increment,user=nil,showAnim=true,ignoreContrary=false,ignoreMirrorArmor=false)
      # Balanced Charges
      if !user.nil? && user.hasActiveAbility?(:BALANCEDCHARGES)
        # Share based on as if the move targeted all allies of the target instead of inflicting same stat change target gets
        if user.pokemon.baseStats[:SPECIAL_DEFENSE] > user.pokemon.baseStats[:SPECIAL_ATTACK] # Minun
          eachAlly do |b| # Recipient's allies
            @battle.pbDisplay(_INTL("{1}'s {2} shared the stat changes with {3}!",user.pbThis,user.abilityName,b.pbThis(true)))
            b.pbLowerStatStage(stat,increment) # No user to prevent infinite loop
          end
        end
      end
      if !stat.is_a?(Array)
        stat = [stat]
      end
      if !@battle.moldBreaker
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary
          return pbRaiseStatStage(stat,increment,user,showAnim,true)
        end
        for s in stat
          # Mirror Armor
          if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && pbCanLowerStatStage?(s) && 
             $fefieldeffect != 11
            battle.pbShowAbilitySplash(self)
            if user && user.index!=@index && !user.hasActiveAbility?(:MIRRORARMOR) && 
               !($fefieldeffect == 37 && user.hasActiveAbility?(:SYNCHRONIZE)) && 
               user.pbCanLowerStatStage?(s,nil,nil,true)
              user.pbLowerStatStageByAbility(s,increment,user,false,false)
              # Trigger user's abilities upon stat loss
              #BattleHandlers.triggerAbilityOnStatLoss(user.ability,user,stat,self) if user.abilityActive?
              abilityOnStatLoss(user) if user.abilityActive?
            else
              @battle.pbDisplay(_INTL("But it failed...",pbThis))
            end
            battle.pbHideAbilitySplash(self)
            return false
          end
          # Synchronize + Psychic Terrain
          if !ignoreMirrorArmor && hasActiveAbility?(:SYNCHRONIZE) && pbCanLowerStatStage?(s) && 
             $fefieldeffect == 37
            battle.pbShowAbilitySplash(self)
            if user && user.index!=@index && !user.hasActiveAbility?([:MIRRORARMOR,:SYNCHRONIZE]) && 
               user.pbCanLowerStatStage?(s,nil,nil,true)
              user.pbLowerStatStageByAbility(s,increment,user,false,false)
              @battle.pbDisplay(_INTL("{1}'s {2} activated, duplicating the stat reduction!",pbThis,abilityName))
              abilityOnStatLoss(user) if user.abilityActive?
            end
            battle.pbHideAbilitySplash(self)
          end
        end
      end
      # Factory Attack scale
      if $fefieldeffect == 17
        for s in stat
          if s == :SPEED
            stat.push(:ATTACK)
            break
          end
        end
      end
      # Luminous Scales
      if hasActiveAbility?(:LUMINOUSSCALES) && !([8,21,26].include?($fefieldeffect) && 
         grounded?) && $fefieldeffect != 22
        maxLen = stat.length # set beforehand so it's not changing as loop progresses
        for i in 0...maxLen
          if stat[i] == :ATTACK
            stat.push(:SPECIAL_ATTACK)
          elsif stat[i] == :DEFENSE
            stat.push(:SPECIAL_DEFENSE)
          elsif stat[i] == :SPECIAL_ATTACK
            stat.push(:ATTACK)
          elsif stat[i] == :SPECIAL_DEFENSE
            stat.push(:DEFENSE)
          end
        end
      end
      # Fairy Tale Field - Rogue
      if $fefieldeffect == 31 && @effects[PBEffects::FairyTaleRoles].include?(8)
        for s in stat
          if s == :EVASION
            if rand(2) == 0
              stat.push(:ATTACK)
              @battle.pbDisplay(_INTL("{1}'s Rogue role scaled its Evasion change with its Attack!"))
            else
              stat.push(:SPEED)
              @battle.pbDisplay(_INTL("{1}'s Rogue role scaled its Evasion change with its Speed!"))
            end
            break
          end
        end
      end
      arrOneStage=[]
      arrTwoStage=[]
      arrThreeStage=[]
      worked=false
      for s in stat
        next if !pbCanLowerStatStage?(s,user)
        incrementTemp=pbLowerStatStageBasic(s,increment,ignoreContrary)
        if incrementTemp>0
          showAnim = false if worked
          @battle.pbCommonAnimation("StatDown",self) if showAnim
          case incrementTemp
          when 1
            arrOneStage.push(GameData::Stat.get(s).name)
          when 2
            arrTwoStage.push(GameData::Stat.get(s).name)
          else
            arrThreeStage.push(GameData::Stat.get(s).name)
          end
          # Trigger abilities upon stat loss
          if abilityActive?
            #BattleHandlers.triggerAbilityOnStatLoss(self.ability,self,stat,user)
            abilityOnStatLoss(user)
          end
          worked=true
        end
      end
      if worked
        texts = []
        for arr in [arrOneStage,arrTwoStage,arrThreeStage]
          if arr.length == 1
            texts.push(arr[0])
          elsif arr.length == 2
            texts.push(arr[0]+" and "+arr[1])
          else # if arr.length > 2
            temp = ""
            for i in 0...arr.length
              temp+=arr[i]
              if i == arr.length-2
                temp+=", and "
              elsif i != arr.length-1
                temp+=", "
              end
            end
            texts.push(temp)
          end
        end
        if texts[0] != ""
          @battle.pbDisplay(_INTL("{1}'s {2} fell!",pbThis,texts[0]))
        end
        if texts[1] != ""
          @battle.pbDisplay(_INTL("{1}'s {2} harshly fell!",pbThis,texts[1]))
        end
        if texts[2] != ""
          @battle.pbDisplay(_INTL("{1}'s {2} severely fell!",pbThis,texts[2]))
        end
        @effects[PBEffects::LashOut] = true
      end
      return worked
    end
  
    def pbLowerStatStageByCause(stat,increment,user,cause,showAnim=true,showMessages=true,ignoreContrary=false,ignoreMirrorArmor=false)
      # Balanced Charges
      if !user.nil? && user.hasActiveAbility?(:BALANCEDCHARGES)
        # Share based on as if the move targeted all allies of the target instead of inflicting same stat change target gets
        if user.pokemon.baseStats[:SPECIAL_DEFENSE] > user.pokemon.baseStats[:SPECIAL_ATTACK] # Minun
          eachAlly do |b| # Recipient's allies
            @battle.pbDisplay(_INTL("{1}'s {2} shared the stat changes with {3}!",user.pbThis,user.abilityName,b.pbThis(true)))
            b.pbLowerStatStage(stat,increment) # No user to prevent infinite loop
          end
        end
      end
      showMessages=false if cause.nil?
      if !stat.is_a?(Array)
        stat = [stat]
      end
      if !@battle.moldBreaker
        # Contrary
        if hasActiveAbility?(:CONTRARY) && !ignoreContrary
          return pbRaiseStatStageByCause(stat,increment,user,cause,showAnim,showMessages,true)
        end
        for s in stat
          # Mirror Armor
          if !ignoreMirrorArmor && hasActiveAbility?(:MIRRORARMOR) && pbCanLowerStatStage?(s) &&
             $fefieldeffect != 11
            battle.pbShowAbilitySplash(self)
            if user && user.index!=@index && !user.hasActiveAbility?(:MIRRORARMOR) && 
               !($fefieldeffect == 37 && user.hasActiveAbility?(:SYNCHRONIZE)) && 
               user.pbCanLowerStatStage?(s,nil,nil,true)
              user.pbLowerStatStageByAbility(s,increment,user,false,false)
              # Trigger user's abilities upon stat loss
              #BattleHandlers.triggerAbilityOnStatLoss(user.ability,user,stat,self) if user.abilityActive?
              abilityOnStatLoss(user) if user.abilityActive?
            else
              @battle.pbDisplay(_INTL("But it failed...",pbThis))
            end
            battle.pbHideAbilitySplash(self)
            return false
          end
          # Synchronize + Psychic Terrain
          if !ignoreMirrorArmor && hasActiveAbility?(:SYNCHRONIZE) && pbCanLowerStatStage?(s) && 
             $fefieldeffect == 37
            battle.pbShowAbilitySplash(self)
            if user && user.index!=@index && !user.hasActiveAbility?([:MIRRORARMOR,:SYNCHRONIZE]) && 
               user.pbCanLowerStatStage?(s,nil,nil,true)
              user.pbLowerStatStageByAbility(s,increment,user,false,false)
              @battle.pbDisplay(_INTL("{1}'s {2} activated, duplicating the stat reduction!",pbThis,abilityName))
              abilityOnStatLoss(user) if user.abilityActive?
            end
            battle.pbHideAbilitySplash(self)
          end
        end
      end
      # Factory Attack scale
      if $fefieldeffect == 17
        for s in stat
          if s == :SPEED
            stat.push(:ATTACK)
            break
          end
        end
      end
      # Luminous Scales
      if hasActiveAbility?(:LUMINOUSSCALES) && !([8,21,26].include?($fefieldeffect) && 
         grounded?) && $fefieldeffect != 22
        maxLen = stat.length # set beforehand so it's not changing as loop progresses
        for i in 0...maxLen
          if stat[i] == :ATTACK
            stat.push(:SPECIAL_ATTACK)
          elsif stat[i] == :DEFENSE
            stat.push(:SPECIAL_DEFENSE)
          elsif stat[i] == :SPECIAL_ATTACK
            stat.push(:ATTACK)
          elsif stat[i] == :SPECIAL_DEFENSE
            stat.push(:DEFENSE)
          end
        end
      end
      # Fairy Tale Field - Rogue
      if $fefieldeffect == 31 && @effects[PBEffects::FairyTaleRoles].include?(8)
        for s in stat
          if s == :EVASION
            if rand(2) == 0
              stat.push(:ATTACK)
              @battle.pbDisplay(_INTL("{1}'s Rogue role scaled its Evasion change with its Attack!"))
            else
              stat.push(:SPEED)
              @battle.pbDisplay(_INTL("{1}'s Rogue role scaled its Evasion change with its Speed!"))
            end
            break
          end
        end
      end
      arrOneStage=[]
      arrTwoStage=[]
      arrThreeStage=[]
      worked=false
      for s in stat
        next if !pbCanLowerStatStage?(s,user)
        incrementTemp=pbLowerStatStageBasic(s,increment,ignoreContrary)
        if incrementTemp>0
          showAnim = false if worked
          @battle.pbCommonAnimation("StatDown",self) if showAnim
          case incrementTemp
          when 1
            arrOneStage.push(GameData::Stat.get(s).name)
          when 2
            arrTwoStage.push(GameData::Stat.get(s).name)
          else
            arrThreeStage.push(GameData::Stat.get(s).name)
          end
          # Trigger abilities upon stat loss
          if abilityActive?
            #BattleHandlers.triggerAbilityOnStatLoss(self.ability,self,stat,user)
            abilityOnStatLoss(user)
          end
          worked=true
        end
      end
      if worked
        if showMessages
          texts = []
          for arr in [arrOneStage,arrTwoStage,arrThreeStage]
            if arr.length == 1
              texts.push(arr[0])
            elsif arr.length == 2
              texts.push(arr[0]+" and "+arr[1])
            else # if arr.length > 2
              temp = ""
              for i in 0...arr.length
                temp+=arr[i]
                if i == arr.length-2
                  temp+=", and "
                elsif i != arr.length-1
                  temp+=", "
                end
              end
              texts.push(temp)
            end
          end
          if user.nil? || user.index==self.index
            if texts[0] != ""
              @battle.pbDisplay(_INTL("{1}'s {2} lowered its {3}!",pbThis,cause,texts[0]))
            end
            if texts[1] != ""
              @battle.pbDisplay(_INTL("{1}'s {2} harshly lowered its {3}!",pbThis,cause,texts[1]))
            end
            if texts[2] != ""
              @battle.pbDisplay(_INTL("{1}'s {2} severely lowered its {3}!",pbThis,cause,texts[2]))
            end
          else
            if texts[0] != ""
              @battle.pbDisplay(_INTL("{1}'s {2} lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),texts[0]))
            end
            if texts[1] != ""
              @battle.pbDisplay(_INTL("{1}'s {2} harshly lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),texts[1]))
            end
            if texts[2] != ""
              @battle.pbDisplay(_INTL("{1}'s {2} severely lowered {3}'s {4}!",user.pbThis,cause,pbThis(true),texts[2]))
            end
          end
        end
        @effects[PBEffects::LashOut] = true
      end
      return worked
    end
    
    def pbLowerStatStageByAbility(stat,increment,user,splashAnim=true,checkContact=false)
      ret = false
      @battle.pbShowAbilitySplash(user) if splashAnim
      if pbCanLowerStatStage?(stat,user,nil,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
         (!checkContact || affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH))
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          ret = pbLowerStatStage(stat,increment,user)
        else
          ret = pbLowerStatStageByCause(stat,increment,user,user.abilityName)
        end
      end
      @battle.pbHideAbilitySplash(user) if splashAnim
      return ret
    end
  
    def pbLowerStatStageEntryAbility(stat,increment,user)
      return false if fainted?
      # NOTE: Substitute intentially blocks Intimidate even if self has Contrary.
      if @effects[PBEffects::Substitute]>0
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} is protected by its substitute!",pbThis))
        else
          @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
             pbThis,user.pbThis(true),user.abilityName))
        end
        return false
      end
      # NOTE: These checks exist to ensure appropriate messages are shown if
      #       Intimidate is blocked somehow (i.e. the messages should mention the
      #       Intimidate ability by name).
      if !hasActiveAbility?(:CONTRARY)
        if pbOwnSide.effects[PBEffects::Mist]>0
          @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
             pbThis,user.pbThis(true),user.abilityName))
          return false
        end
        if abilityActive?
          if statLossImmunityByAbility?(stat,false) ||
             #BattleHandlers.triggerStatLossImmunityAbility(self.ability,self,:ATTACK,@battle,false) ||
             #BattleHandlers.triggerStatLossImmunityAbilityNonIgnorable(self.ability,self,:ATTACK,@battle,false) ||
             hasActiveAbility?(:INNERFOCUS) || hasActiveAbility?(:OWNTEMPO) || hasActiveAbility?(:OBLIVIOUS) || 
             hasActiveAbility?(:SCRAPPY) || hasActiveAbility?(:SOUNDPROOF) && $fefieldeffect == 6
            @battle.pbShowAbilitySplash(self) if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
               pbThis,abilityName,user.pbThis(true),user.abilityName))
            @battle.pbHideAbilitySplash(self) if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            return false
          end
        end
        eachAlly do |b|
          next if !b.abilityActive?
          #if BattleHandlers.triggerStatLossImmunityAllyAbility(b.ability,b,self,:ATTACK,@battle,false)
          if statLossImmunityByAllyAbility?(b,stat,false)
            @battle.pbShowAbilitySplash(b) if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by {4}'s {5}!",
               pbThis,user.pbThis(true),user.abilityName,b.pbThis(true),b.abilityName))
            @battle.pbHideAbilitySplash(b) if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            return false
          end
        end
        if user.hasActiveAbility?(:INTIMIDATE)
          if $fefieldeffect == 29 && (pbHasType?(:FAIRY) || pbHasType?(:NORMAL) || 
             pbHasType?(:PSYCHIC))
            @battle.pbDisplay(_INTL("The heavens protect {1} from {2}'s {3}!",pbThis(true),user.pbThis(true),user.abilityName))
            return false
          end
        end
      end
      return false if !pbCanLowerStatStage?(stat,user)
      ret = false
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        ret = pbLowerStatStageByAbility(stat,increment,user,false)
        pbRaiseStatStageByAbility(:SPEED,1,self) if hasActiveAbility?(:RATTLED) && ret
      else
        ret = pbLowerStatStageByCause(stat,increment,user,user.abilityName)
        pbLowerStatStageByCause(:SPEED,1,self,self.abilityName) if hasActiveAbility?(:RATTLED) && ret
      end
      return ret
    end
  
    #=============================================================================
    # Reset stat stages
    #=============================================================================
    def hasAlteredStatStages?
      GameData::Stat.each_battle { |s| return true if @stages[s.id] != 0 }
      return false
    end
  
    def hasRaisedStatStages?
      GameData::Stat.each_battle { |s| return true if @stages[s.id] > 0 }
      return false
    end
  
    def hasLoweredStatStages?
      GameData::Stat.each_battle { |s| return true if @stages[s.id] < 0 }
      return false
    end
  
    def pbResetStatStages
      GameData::Stat.each_battle { |s| @stages[s.id] = 0 }
    end
  end
  