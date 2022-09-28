#===============================================================================
# Power is doubled if the target's HP is down to 1/2 or less. (Brine)
#===============================================================================
class PokeBattle_Move_080 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 2 if target.hp<=target.totalhp/2
      return baseDmg
    end
  end
  
  
  
  #===============================================================================
  # Power is doubled if the user has lost HP due to the target's move this round.
  # (Avalanche, Revenge, Trashalanche)
  #===============================================================================
  class PokeBattle_Move_081 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 2 if user.lastAttacker.include?(target.index)
      return baseDmg
    end
  end
  
  
  
  #===============================================================================
  # Power is doubled if the target has already lost HP this round. (Assurance)
  #===============================================================================
  class PokeBattle_Move_082 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 2 if target.tookDamage
      return baseDmg
    end
  end
  
  
  
  #===============================================================================
  # Power is doubled if a user's ally has already used this move this round. (Round)
  # If an ally is about to use the same move, make it go next, ignoring priority.
  #===============================================================================
  class PokeBattle_Move_083 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 2 if user.pbOwnSide.effects[PBEffects::Round]
      return baseDmg
    end
  
    def pbEffectGeneral(user)
      user.pbOwnSide.effects[PBEffects::Round] = true
      user.eachAlly do |b|
        next if @battle.choices[b.index][0]!=:UseMove || b.movedThisRound?
        next if @battle.choices[b.index][2].function!=@function
        b.effects[PBEffects::MoveNext] = true
        b.effects[PBEffects::Quash]    = 0
        break
      end
    end
  end
  
  
  
  #===============================================================================
  # Power is doubled if the target has already moved this round. (Payback)
  #===============================================================================
  class PokeBattle_Move_084 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      if @battle.choices[target.index][0]!=:None &&
         ((@battle.choices[target.index][0]!=:UseMove &&
         @battle.choices[target.index][0]!=:Shift) || target.movedThisRound?)
        baseDmg *= 2
      end
      return baseDmg
    end
  end
  
  
  
  #===============================================================================
  # Power is doubled if a user's teammate fainted last round. (Retaliate)
  #===============================================================================
  class PokeBattle_Move_085 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      lrf = user.pbOwnSide.effects[PBEffects::LastRoundFainted]
      baseDmg *= 2 if lrf>=0 && lrf==@battle.turnCount-1
      return baseDmg
    end
  end
  
  
  
  #===============================================================================
  # Power is doubled if the user has no held item. (Acrobatics)
  #===============================================================================
  class PokeBattle_Move_086 < PokeBattle_Move
    def pbBaseDamageMultiplier(damageMult,user,target)
      damageMult *= 2 if !user.item || $fefieldeffect == 6 || pbIsGem?(user.item)
      return damageMult
    end
  end
  
  
  
  #===============================================================================
  # Power is doubled in weather. Type changes depending on the weather. (Weather Ball)
  #===============================================================================
  class PokeBattle_Move_087 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 2 if @battle.pbWeather != :None && !([:Sun,:Rain,:HarshSun,:HeavyRain].include?(@battle.pbWeather) && 
                      user.hasUtilityUmbrella?) || [11,43].include?($fefieldeffect)
      return baseDmg
    end
  
    def pbBaseTypes(user)
      ret = [:NORMAL]
      if $fefieldeffect == 11
        ret = [:POISON]
      elsif $fefieldeffect == 43
        ret = [:FLYING]
      end
      case @battle.pbWeather
      when :Sun, :HarshSun
        ret = [:FIRE] if GameData::Type.exists?(:FIRE)
      when :Rain, :HeavyRain
        ret = [:WATER] if GameData::Type.exists?(:WATER)
      when :Sandstorm
        ret = [:ROCK] if GameData::Type.exists?(:ROCK)
      when :Hail
        ret = [:ICE] if GameData::Type.exists?(:ICE)
      when :StrongWinds
        ret = [:FLYING] if GameData::Type.exists?(:FLYING)
      end
      ret = [:NORMAL] if user.hasUtilityUmbrella? && [:FIRE,:WATER].include?(ret)
      return ret
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      t = pbBaseTypes(user)
      hitNum = 1 if t == [:FIRE]   # Type-specific anims
      hitNum = 2 if t == [:WATER]
      hitNum = 3 if t == [:ROCK]
      hitNum = 4 if t == [:ICE]
      super
    end
  end
  
  
  
  #===============================================================================
  # Interrupts a foe switching out or using U-turn/Volt Switch/Parting Shot. Power
  # is doubled in that case. (Pursuit)
  # (Handled in Battle's pbAttackPhase): Makes this attack happen before switching.
  #===============================================================================
  class PokeBattle_Move_088 < PokeBattle_Move
    def pbAccuracyCheck(user,target)
      return true if @battle.switching
      return super
    end
  
    def pbBaseDamage(baseDmg,user,target)
      baseDmg *= 2 if @battle.switching
      return baseDmg
    end
  end
  
  
  
  #===============================================================================
  # Power increases with the user's happiness. (Return)
  #===============================================================================
  class PokeBattle_Move_089 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      return [(user.happiness*2/5).floor,1].max
    end
  end
  
  
  
  #===============================================================================
  # Power decreases with the user's happiness. (Frustration)
  #===============================================================================
  class PokeBattle_Move_08A < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      return [((255-user.happiness)*2/5).floor,1].max
    end
  end
  
  
  
  #===============================================================================
  # Power increases with the user's HP. (Eruption, Water Spout)
  #===============================================================================
  class PokeBattle_Move_08B < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      return [150*user.hp/user.totalhp,1].max
    end
  end
  
  
  
  #===============================================================================
  # Power increases with the target's HP. (Crush Grip, Wring Out)
  #===============================================================================
  class PokeBattle_Move_08C < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      return [120*target.hp/target.totalhp,1].max
    end
  end
  
  
  
  #===============================================================================
  # Power increases the quicker the target is than the user. (Gyro Ball)
  #===============================================================================
  class PokeBattle_Move_08D < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      return [[(25*target.pbSpeed/user.pbSpeed).floor,150].min,1].max
    end
  end
  
  
  
  #===============================================================================
  # Power increases with the user's positive stat changes (ignores negative ones).
  # (Power Trip, Stored Power)
  #===============================================================================
  class PokeBattle_Move_08E < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      mult = 1
      GameData::Stat.each_battle { |s| mult += user.stages[s.id] if user.stages[s.id] > 0 }
      return 20 * mult
    end
  end
  
  
  
  #===============================================================================
  # Power increases with the target's positive stat changes (ignores negative ones).
  # (Punishment)
  #===============================================================================
  class PokeBattle_Move_08F < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      mult = 3
      GameData::Stat.each_battle { |s| mult += target.stages[s.id] if target.stages[s.id] > 0 }
      return [20 * mult, 200].min
    end
  end
  
  
  
  #===============================================================================
  # Power and type depends on the user's IVs. (Hidden Power)
  #===============================================================================
  class PokeBattle_Move_090 < PokeBattle_Move
    def pbBaseTypes(user)
      hp = pbHiddenPower(user)
      return [hp[0]]
    end
  
    def pbBaseDamage(baseDmg,user,target)
      return super if Settings::MECHANICS_GENERATION >= 6
      hp = pbHiddenPower(user)
      return hp[1]
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      case pbHiddenPower(user)[0]
      when :BUG
        hitNum = 1
      when :DARK
        hitNum = 2
      when :DRAGON
        hitNum = 3
      when :ELECTRIC
        hitNum = 4
      when :ELECTRIC
        hitNum = 5
      when :FIGHTING
        hitNum = 6
      when :FIRE
        hitNum = 7
      when :FLYING
        hitNum = 8
      when :GHOST
        hitNum = 9
      when :GRASS
        hitNum = 10
      when :GROUND
        hitNum = 11
      when :ICE
        hitNum = 12
      when :POISON
        hitNum = 13
      when :PSYCHIC
        hitNum = 14
      when :ROCK
        hitNum = 15
      when :STEEL
        hitNum = 16
      when :WATER
        hitNum = 17
      end
      super
    end
  end
  
  
  
  def pbHiddenPower(pkmn)
    # NOTE: This allows Hidden Power to be Fairy-type (if you have that type in
    #       your game). I don't care that the official games don't work like that.
    iv = pkmn.iv
    idxType = 0; power = 60
    types = []
    GameData::Type.each { |t| types.push(t.id) if !t.pseudo_type && ![:NORMAL, :SHADOW].include?(t.id)}
    types.sort! { |a, b| GameData::Type.get(a).id_number <=> GameData::Type.get(b).id_number }
    idxType |= (iv[:HP]&1)
    idxType |= (iv[:ATTACK]&1)<<1
    idxType |= (iv[:DEFENSE]&1)<<2
    idxType |= (iv[:SPEED]&1)<<3
    idxType |= (iv[:SPECIAL_ATTACK]&1)<<4
    idxType |= (iv[:SPECIAL_DEFENSE]&1)<<5
    idxType = (types.length-1)*idxType/63
    type = types[idxType]
    if Settings::MECHANICS_GENERATION <= 5
      powerMin = 30
      powerMax = 70
      power |= (iv[:HP]&2)>>1
      power |= (iv[:ATTACK]&2)
      power |= (iv[:DEFENSE]&2)<<1
      power |= (iv[:SPEED]&2)<<2
      power |= (iv[:SPECIAL_ATTACK]&2)<<3
      power |= (iv[:SPECIAL_DEFENSE]&2)<<4
      power = powerMin+(powerMax-powerMin)*power/63
    end
    return [type,power]
  end
  
  
  
  #===============================================================================
  # Power doubles for each consecutive use. (Fury Cutter)
  #===============================================================================
  class PokeBattle_Move_091 < PokeBattle_Move
    def pbChangeUsageCounters(user,specialUsage)
      oldVal = user.effects[PBEffects::FuryCutter]
      super
      maxMult = 1
      while (@baseDamage<<(maxMult-1))<160
        maxMult += 1   # 1-4 for base damage of 20, 1-3 for base damage of 40
      end
      user.effects[PBEffects::FuryCutter] = (oldVal>=maxMult) ? maxMult : oldVal+1
    end
  
    def pbBaseDamage(baseDmg,user,target)
      return baseDmg<<(user.effects[PBEffects::FuryCutter]-1)
    end
  end
  
  
  
  #===============================================================================
  # Power is multiplied by the number of consecutive rounds in which this move was
  # used by any Pokémon on the user's side. (Echoed Voice)
  #===============================================================================
  class PokeBattle_Move_092 < PokeBattle_Move
    def pbChangeUsageCounters(user,specialUsage)
      oldVal = user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]
      super
      if !user.pbOwnSide.effects[PBEffects::EchoedVoiceUsed]
        user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter] = (oldVal>=5) ? 5 : oldVal+1
      end
      user.pbOwnSide.effects[PBEffects::EchoedVoiceUsed] = true
    end
  
    def pbBaseDamage(baseDmg,user,target)
      return baseDmg*user.pbOwnSide.effects[PBEffects::EchoedVoiceCounter]   # 1-5
    end
  end
  
  
  
  #===============================================================================
  # User rages until the start of a round in which they don't use this move. (Rage)
  # (Handled in Battler's pbProcessMoveAgainstTarget): Ups rager's Attack by 1
  # stage each time it loses HP due to a move.
  #===============================================================================
  class PokeBattle_Move_093 < PokeBattle_Move
    def pbEffectGeneral(user)
      user.effects[PBEffects::Rage] = true if $fefieldeffect != 9
    end
  end
  
  
  
  #===============================================================================
  # Randomly damages or heals the target. (Present)
  # NOTE: Apparently a Normal Gem should be consumed even if this move will heal,
  #       but I think that's silly so I've omitted that effect.
  #===============================================================================
  class PokeBattle_Move_094 < PokeBattle_Move
    def pbOnStartUse(user,targets)
      @presentDmg = 0   # 0 = heal, >0 = damage
      r = @battle.pbRandom(100)
      if r<40;    @presentDmg = 40
      elsif r<70; @presentDmg = 80
      elsif r<80; @presentDmg = 120
      end
    end
  
    def pbFailsAgainstTarget?(user,target)
      return false if @presentDmg>0
      if !target.canHeal?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbDamagingMove?
      return false if @presentDmg==0
      return super
    end
  
    def pbBaseDamage(baseDmg,user,target)
      return @presentDmg
    end
  
    def pbEffectAgainstTarget(user,target)
      return if @presentDmg>0
      target.pbRecoverHP(target.totalhp/4)
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      hitNum = 1 if @presentDmg==0   # Healing anim
      super
    end
  end
  
  
  
  #===============================================================================
  # Power is chosen at random. Power is doubled if the target is using Dig. Hits
  # some semi-invulnerable targets. (Magnitude)
  #===============================================================================
  class PokeBattle_Move_095 < PokeBattle_Move
    def hitsDiggingTargets?; return true; end
  
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
      @battle.pbDisplay(_INTL("Magnitude {1}!",magni))
    end
  
    def pbBaseDamage(baseDmg,user,target)
      return @magnitudeDmg
    end
  
    def pbModifyDamage(damageMult,user,target)
      damageMult *= 2 if target.inTwoTurnAttack?("0CA")   # Dig
      return damageMult
    end
  end
  
  
  
  #===============================================================================
  # Power and type depend on the user's held berry. Destroys the berry.
  # (Natural Gift)
  #===============================================================================
  class PokeBattle_Move_096 < PokeBattle_Move
    def initialize(battle,move)
      super
      @typeArray = {
         :NORMAL   => [:CHILANBERRY],
         :FIRE     => [:CHERIBERRY,  :BLUKBERRY,   :WATMELBERRY, :OCCABERRY],
         :WATER    => [:CHESTOBERRY, :NANABBERRY,  :DURINBERRY,  :PASSHOBERRY],
         :ELECTRIC => [:PECHABERRY,  :WEPEARBERRY, :BELUEBERRY,  :WACANBERRY],
         :GRASS    => [:RAWSTBERRY,  :PINAPBERRY,  :RINDOBERRY,  :LIECHIBERRY],
         :ICE      => [:ASPEARBERRY, :POMEGBERRY,  :YACHEBERRY,  :GANLONBERRY],
         :FIGHTING => [:LEPPABERRY,  :KELPSYBERRY, :CHOPLEBERRY, :SALACBERRY],
         :POISON   => [:ORANBERRY,   :QUALOTBERRY, :KEBIABERRY,  :PETAYABERRY],
         :GROUND   => [:PERSIMBERRY, :HONDEWBERRY, :SHUCABERRY,  :APICOTBERRY],
         :FLYING   => [:LUMBERRY,    :GREPABERRY,  :COBABERRY,   :LANSATBERRY],
         :PSYCHIC  => [:SITRUSBERRY, :TAMATOBERRY, :PAYAPABERRY, :STARFBERRY],
         :BUG      => [:FIGYBERRY,   :CORNNBERRY,  :TANGABERRY,  :ENIGMABERRY],
         :ROCK     => [:WIKIBERRY,   :MAGOSTBERRY, :CHARTIBERRY, :MICLEBERRY],
         :GHOST    => [:MAGOBERRY,   :RABUTABERRY, :KASIBBERRY,  :CUSTAPBERRY],
         :DRAGON   => [:AGUAVBERRY,  :NOMELBERRY,  :HABANBERRY,  :JABOCABERRY],
         :DARK     => [:IAPAPABERRY, :SPELONBERRY, :COLBURBERRY, :ROWAPBERRY, :MARANGABERRY],
         :STEEL    => [:RAZZBERRY,   :PAMTREBERRY, :BABIRIBERRY],
         :FAIRY    => [:ROSELIBERRY, :KEEBERRY]
      }
      @damageArray = {
         60 => [:CHERIBERRY,  :CHESTOBERRY, :PECHABERRY,  :RAWSTBERRY,  :ASPEARBERRY,
                :LEPPABERRY,  :ORANBERRY,   :PERSIMBERRY, :LUMBERRY,    :SITRUSBERRY,
                :FIGYBERRY,   :WIKIBERRY,   :MAGOBERRY,   :AGUAVBERRY,  :IAPAPABERRY,
                :RAZZBERRY,   :OCCABERRY,   :PASSHOBERRY, :WACANBERRY,  :RINDOBERRY,
                :YACHEBERRY,  :CHOPLEBERRY, :KEBIABERRY,  :SHUCABERRY,  :COBABERRY,
                :PAYAPABERRY, :TANGABERRY,  :CHARTIBERRY, :KASIBBERRY,  :HABANBERRY,
                :COLBURBERRY, :BABIRIBERRY, :CHILANBERRY, :ROSELIBERRY],
         70 => [:BLUKBERRY,   :NANABBERRY,  :WEPEARBERRY, :PINAPBERRY,  :POMEGBERRY,
                :KELPSYBERRY, :QUALOTBERRY, :HONDEWBERRY, :GREPABERRY,  :TAMATOBERRY,
                :CORNNBERRY,  :MAGOSTBERRY, :RABUTABERRY, :NOMELBERRY,  :SPELONBERRY,
                :PAMTREBERRY],
         80 => [:WATMELBERRY, :DURINBERRY,  :BELUEBERRY,  :LIECHIBERRY, :GANLONBERRY,
                :SALACBERRY,  :PETAYABERRY, :APICOTBERRY, :LANSATBERRY, :STARFBERRY,
                :ENIGMABERRY, :MICLEBERRY,  :CUSTAPBERRY, :JABOCABERRY, :ROWAPBERRY,
                :KEEBERRY,    :MARANGABERRY]
      }
    end
  
    def pbMoveFailed?(user,targets)
      # NOTE: Unnerve does not stop a Pokémon using this move.
      item = user.item
      if !item || !item.is_berry? || !user.itemActive?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    # NOTE: The AI calls this method via pbCalcType, but it involves user.item
    #       which here is assumed to be not nil (because item.id is called). Since
    #       the AI won't want to use it if the user has no item anyway, perhaps
    #       this is good enough.
    def pbBaseTypes(user)
      item = user.item
      ret = [:NORMAL]
      @typeArray.each do |type, items|
        next if !items.include?(user.item_id)
        ret = [type] if GameData::Type.exists?(type)
        break
      end
      return ret
    end
  
    # This is a separate method so that the AI can use it as well
    def pbNaturalGiftBaseDamage(heldItem)
      ret = 1
      @damageArray.each do |dmg, items|
        next if !items.include?(heldItem)
        ret = dmg
        ret += 20 if Settings::MECHANICS_GENERATION >= 6
        break
      end
      return ret
    end
  
    def pbBaseDamage(baseDmg,user,target)
      return pbNaturalGiftBaseDamage(user.item_id)
    end
  
    def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
      # NOTE: The item is consumed even if this move was Protected against or it
      #       missed. The item is not consumed if the target was switched out by
      #       an effect like a target's Red Card.
      # NOTE: There is no item consumption animation.
      user.pbConsumeItem(true,true,false) if user.item
      if $fefieldeffect == 42
        targets do |b|
          b.pbCheckAndInflictRandomStatus(user,false,self)
        end
      end
    end
  end
  
  
  
  #===============================================================================
  # Power increases the less PP this move has. (Trump Card)
  #===============================================================================
  class PokeBattle_Move_097 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      dmgs = [200,80,60,50,40]
      ppLeft = [@pp,dmgs.length-1].min   # PP is reduced before the move is used
      return dmgs[ppLeft]
    end
  end
  
  
  
  #===============================================================================
  # Power increases the less HP the user has. (Flail, Reversal)
  #===============================================================================
  class PokeBattle_Move_098 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      ret = 20
      n = 48*user.hp/user.totalhp
      if n<2;     ret = 200
      elsif n<5;  ret = 150
      elsif n<10; ret = 100
      elsif n<17; ret = 80
      elsif n<33; ret = 40
      end
      return ret
    end
  end
  
  
  
  #===============================================================================
  # Power increases the quicker the user is than the target. (Electro Ball)
  #===============================================================================
  class PokeBattle_Move_099 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      ret = 40
      n = user.pbSpeed/target.pbSpeed
      if n>=4;    ret = 150
      elsif n>=3; ret = 120
      elsif n>=2; ret = 80
      elsif n>=1; ret = 60
      end
      return ret
    end
  end
  
  
  
  #===============================================================================
  # Power increases the heavier the target is. (Grass Knot, Low Kick)
  #===============================================================================
  class PokeBattle_Move_09A < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      ret = 20
      weight = target.pbWeight
      if weight>=2000;    ret = 120
      elsif weight>=1000; ret = 100
      elsif weight>=500;  ret = 80
      elsif weight>=250;  ret = 60
      elsif weight>=100;  ret = 40
      end
      return ret
    end
  end
  
  
  
  #===============================================================================
  # Power increases the heavier the user is than the target. (Heat Crash, Heavy Slam)
  # Does double damage and has perfect accuracy if the target is Minimized.
  #===============================================================================
  class PokeBattle_Move_09B < PokeBattle_Move
    def tramplesMinimize?(param=1)
      return true if Settings::MECHANICS_GENERATION >= 7   # Perfect accuracy and double damage
      return super
    end
  
    def pbBaseDamage(baseDmg,user,target)
      ret = 40
      n = (user.pbWeight/target.pbWeight).floor
      if n>=5;    ret = 120
      elsif n>=4; ret = 100
      elsif n>=3; ret = 80
      elsif n>=2; ret = 60
      end
      return ret
    end
  end
  
  
  
  #===============================================================================
  # Powers up the ally's attack this round by 1.5. (Helping Hand)
  #===============================================================================
  class PokeBattle_Move_09C < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbFailsAgainstTarget?(user,target)
      if target.fainted? || target.effects[PBEffects::HelpingHand]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return true if pbMoveFailedTargetAlreadyMoved?(target)
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.effects[PBEffects::HelpingHand] = true
      @battle.pbDisplay(_INTL("{1} is ready to help {2}!",user.pbThis,target.pbThis(true)))
    end
  end
  
  
  
  #===============================================================================
  # Weakens Electric attacks. (Mud Sport)
  #===============================================================================
  class PokeBattle_Move_09D < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if @battle.field.effects[PBEffects::MudSportField]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      @battle.field.effects[PBEffects::MudSportField] = 5
      @battle.pbDisplay(_INTL("Electricity's power was weakened!"))
      if $fefieldeffect == 8
        if @battle.field.effects[PBEffects::WaterSportField] == 0
          @battle.field.effects[PBEffects::WaterSportField] = 5
          @battle.pbDisplay(_INTL("Fire's power was weakened!"))
        end
        if user.stages[:SPEED] < 0 && user.grounded?
          user.pbRaiseStatStageByCause(:SPEED,-1*user.stages[:SPEED],user,nil,true,false)
          @battle.pbDisplay(_INTL("{1} removed the mud from itself to execute the attack, resetting its Speed stat!",user.pbThis))
        end
      end
    end
  end
  
  
  
  #===============================================================================
  # Weakens Fire attacks. (Water Sport)
  #===============================================================================
  class PokeBattle_Move_09E < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if @battle.field.effects[PBEffects::WaterSportField]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      if $fefieldeffect == 21
        @battle.field.effects[PBEffects::WaterSportField] = 8
      else
        @battle.field.effects[PBEffects::WaterSportField] = 5
      end
      @battle.pbDisplay(_INTL("Fire's power was weakened!"))
      if $fefieldeffect == 8 && @battle.field.effects[PBEffects::MudSportField] == 0
        @battle.field.effects[PBEffects::MudSportField] = 5
        @battle.pbDisplay(_INTL("Electricity's power was weakened!"))
      end
    end
  end
  
  
  
  #===============================================================================
  # Type depends on the user's held item. (Judgment, Multi-Attack, Techno Blast)
  #===============================================================================
  class PokeBattle_Move_09F < PokeBattle_Move
    def initialize(battle,move)
      super
      if @id == :JUDGMENT
        @itemTypes = {
           :FISTPLATE   => :FIGHTING,
           :SKYPLATE    => :FLYING,
           :TOXICPLATE  => :POISON,
           :EARTHPLATE  => :GROUND,
           :STONEPLATE  => :ROCK,
           :INSECTPLATE => :BUG,
           :SPOOKYPLATE => :GHOST,
           :IRONPLATE   => :STEEL,
           :FLAMEPLATE  => :FIRE,
           :SPLASHPLATE => :WATER,
           :MEADOWPLATE => :GRASS,
           :ZAPPLATE    => :ELECTRIC,
           :MINDPLATE   => :PSYCHIC,
           :ICICLEPLATE => :ICE,
           :DRACOPLATE  => :DRAGON,
           :DREADPLATE  => :DARK,
           :PIXIEPLATE  => :FAIRY
        }
      elsif @id == :TECHNOBLAST
        @itemTypes = {
           :SHOCKDRIVE => :ELECTRIC,
           :BURNDRIVE  => :FIRE,
           :CHILLDRIVE => :ICE,
           :DOUSEDRIVE => :WATER
        }
      elsif @id == :MULTIATTACK
        @itemTypes = {
           :FIGHTINGMEMORY => :FIGHTING,
           :FLYINGMEMORY   => :FLYING,
           :POISONMEMORY   => :POISON,
           :GROUNDMEMORY   => :GROUND,
           :ROCKMEMORY     => :ROCK,
           :BUGMEMORY      => :BUG,
           :GHOSTMEMORY    => :GHOST,
           :STEELMEMORY    => :STEEL,
           :FIREMEMORY     => :FIRE,
           :WATERMEMORY    => :WATER,
           :GRASSMEMORY    => :GRASS,
           :ELECTRICMEMORY => :ELECTRIC,
           :PSYCHICMEMORY  => :PSYCHIC,
           :ICEMEMORY      => :ICE,
           :DRAGONMEMORY   => :DRAGON,
           :DARKMEMORY     => :DARK,
           :FAIRYMEMORY    => :FAIRY
        }
      end
    end
  
    def pbBaseTypes(user)
      ret = [:NORMAL]
      if user.itemActive?
        @itemTypes.each do |item, itemType|
          next if user.item != item
          ret = [itemType] if GameData::Type.exists?(itemType)
          break
        end
      end
      return ret
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      t = pbBaseTypes(user)
      if @id == :TECHNOBLAST   # Type-specific anim
        hitNum = 1 if t == [:ELECTRIC]
        hitNum = 2 if t == [:FIRE]
        hitNum = 3 if t == [:ICE]
        hitNum = 4 if t == [:WATER]
      elsif @id == :JUDGMENT
        hitNum = 1 if t == [:BUG]
        hitNum = 2 if t == [:DARK]
        hitNum = 3 if t == [:DRAGON]
        hitNum = 4 if t == [:ELECTRIC]
        hitNum = 5 if t == [:FAIRY]
        hitNum = 6 if t == [:FIGHTING]
        hitNum = 7 if t == [:FIRE]
        hitNum = 8 if t == [:FLYING]
        hitNum = 9 if t == [:GHOST]
        hitNum = 10 if t == [:GRASS]
        hitNum = 11 if t == [:GROUND]
        hitNum = 12 if t == [:ICE]
        hitNum = 13 if t == [:POISON]
        hitNum = 14 if t == [:PSYCHIC]
        hitNum = 15 if t == [:QMARKS]
        hitNum = 16 if t == [:ROCK]
        hitNum = 17 if t == [:STEEL]
        hitNum = 18 if t == [:WATER]
      elsif @id == :MULTIATTACK
        hitNum = 1 if t == [:BUG]
        hitNum = 2 if t == [:DARK]
        hitNum = 3 if t == [:DRAGON]
        hitNum = 4 if t == [:ELECTRIC]
        hitNum = 5 if t == [:FAIRY]
        hitNum = 6 if t == [:FIGHTING]
        hitNum = 7 if t == [:FIRE]
        hitNum = 8 if t == [:FLYING]
        hitNum = 9 if t == [:GHOST]
        hitNum = 10 if t == [:GRASS]
        hitNum = 11 if t == [:GROUND]
        hitNum = 12 if t == [:ICE]
        hitNum = 13 if t == [:POISON]
        hitNum = 14 if t == [:PSYCHIC]
        hitNum = 15 if t == [:ROCK]
        hitNum = 16 if t == [:STEEL]
        hitNum = 17 if t == [:WATER]
      end
      super
    end
    
    def pbEffectAgainstTarget(user,target)
      return if target.damageState.substitute || $fefieldeffect != 24 || @id != :TECHNOBLAST ||
                !user.itemActive?
      if @battle.pbRandom(10) < 3
        case user.item
        when :BURNDRIVE
          target.pbBurn(user) if target.pbCanBurn?(user,false,self)
        when :CHILLDRIVE
          target.pbFreeze(user) if target.pbCanFreeze?(user,false,self)
        when :DOUSEDRIVE
          target.pbFlinch(user)
        when :SHOCKDRIVE
          target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
        end
      end
    end
  end
  
  
  
  #===============================================================================
  # This attack is always a critical hit. (Frost Breath, Storm Throw)
  #===============================================================================
  class PokeBattle_Move_0A0 < PokeBattle_Move
    def pbCritialOverride(user,target); return 1; end
  end
  
  
  
  #===============================================================================
  # For 5 rounds, foes' attacks cannot become critical hits. (Lucky Chant)
  #===============================================================================
  class PokeBattle_Move_0A1 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if user.pbOwnSide.effects[PBEffects::LuckyChant]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      if [9,29,31].include?($fefieldeffect)
        user.pbOwnSide.effects[PBEffects::LuckyChant] = 8
      else
        user.pbOwnSide.effects[PBEffects::LuckyChant] = 5
      end
      @battle.pbDisplay(_INTL("The Lucky Chant shielded {1} from critical hits!",user.pbTeam(true)))
    end
  end
  
  
  
  #===============================================================================
  # For 5 rounds, lowers power of physical attacks against the user's side.
  # (Reflect)
  #===============================================================================
  class PokeBattle_Move_0A2 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if user.pbOwnSide.effects[PBEffects::Reflect]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.pbOwnSide.effects[PBEffects::Reflect] = 5
      user.pbOwnSide.effects[PBEffects::Reflect] = (user.pbOwnSide.effects[PBEffects::Reflect]*1.5).ceil if user.hasActiveItem?(:LIGHTCLAY)
      user.pbOwnSide.effects[PBEffects::Reflect] = (user.pbOwnSide.effects[PBEffects::Reflect]*1.5).ceil if [9,13,25,30,37,46].include?($fefieldeffect)
      @battle.pbDisplay(_INTL("{1} raised {2}'s Defense!",@name,user.pbTeam(true)))
      if $fefieldeffect == 30
        user.pbRaiseStatStage(:EVASION,1,user)
      end
    end
  end
  
  
  
  #===============================================================================
  # For 5 rounds, lowers power of special attacks against the user's side. (Light Screen)
  #===============================================================================
  class PokeBattle_Move_0A3 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if user.pbOwnSide.effects[PBEffects::LightScreen]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.pbOwnSide.effects[PBEffects::LightScreen] = (user.pbOwnSide.effects[PBEffects::LightScreen]*1.5).ceil if user.hasActiveItem?(:LIGHTCLAY)
      user.pbOwnSide.effects[PBEffects::LightScreen] = (user.pbOwnSide.effects[PBEffects::LightScreen]*1.5).ceil if [9,13,25,30,37,46].include?($fefieldeffect)
      @battle.pbDisplay(_INTL("{1} raised {2}'s Special Defense!",@name,user.pbTeam(true)))
      if $fefieldeffect == 30
        user.pbRaiseStatStage(:EVASION,1,user)
      end
    end
  end
  
  
  
  #===============================================================================
  # Effect depends on the environment. (Secret Power)
  #===============================================================================
  class PokeBattle_Move_0A4 < PokeBattle_Move
    def flinchingMove?; return [5,14,27,44].include?($fefieldeffect); end
  
    # NOTE: This intentionally doesn't use def pbAdditionalEffect, because that
    #       method is called per hit and this move's additional effect only occurs
    #       once per use, after all the hits have happened (two hits are possible
    #       via Parental Bond).
    def pbEffectAfterAllHits(user,target)
      return if target.fainted? || $fefieldeffect == 0
      return if target.damageState.unaffected || target.damageState.substitute
      return if user.hasActiveAbility?(:SHEERFORCE) || target.hasShieldDust? && !@battle.moldBreaker
      chance = pbAdditionalEffectChance(user,target)
      return if @battle.pbRandom(100)>=chance
      case $fefieldeffect
      when 31,42 # Fairy Tale Field, Bewitched Woods
        target.pbSleep if target.pbCanSleep?(user,false,self)
      when 7 # Volcanic Field
        target.pbBurn(user) if target.pbCanBurn?(user,false,self)
      when 1,18 # Electric Terrain, Short-Circuit Field
        target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
      when 28,39 # Snowy Mountain, Frozen Dimensional Field
        target.pbFreeze if target.pbCanFreeze?(user,false,self)
      when 26 # Murkwater Surface
        target.pbPoison if target.pbCanPoison?(user,false,self)
      when 12,49 # Desert, Xeric Shrubland
        if target.pbCanLowerStatStage?(:ATTACK,user,self)
          target.pbLowerStatStage(:ATTACK,1,user)
        end
      when 10 # Corrosive Field
        if target.pbCanLowerStatStage?(:DEFENSE,user,self)
          target.pbLowerStatStage(:DEFENSE,1,user)
        end
      when 29 # Holy Field
        if target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user,self)
          target.pbLowerStatStage(:SPECIAL_ATTACK,1,user)
        end
      when 35,38,41 # New World, Dimensional Field, Corrupted Cave
        if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
          target.pbLowerStatStage(:SPECIAL_DEFENSE,1,user)
        end
      when 8,46 # Swamp, Subzero Field
        if target.pbCanLowerStatStage?(:SPEED,user,self)
          target.pbLowerStatStage(:SPEED,1,user)
        end
      when 4,16 # Dark Crystal Cavern, Volcanic Top Field
        if target.pbCanLowerStatStage?(:ACCURACY,user,self)
          target.pbLowerStatStage(:ACCURACY,1,user)
        end
      when 22,34 # Underwater
        if target.pbCanLowerStatStage?(:EVASION,user,self)
          target.pbLowerStatStage(:EVASION,1,user)
        end
      when 20,45,47 # Ashen Beach, Boxing Ring, Jungle
        if user.pbCanRaiseStatStage?(:ATTACK,user,self)
          user.pbRaiseStatStage(:ATTACK,1,user)
        end
      when 15,23 # Forest Field, Cave
        if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
          user.pbRaiseStatStage(:DEFENSE,1,user)
        end
      when 2,25,33 # Grassy Terrain, Crystal Cavern, Flower Garden Field
        if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
          user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
        end
      when 3,11,48 # Misty Terrain, Corrosive Mist Field, Beach
        if user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
          user.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user)
        end
      when 13,17,21,43 # Icy Cave, Factory Field, Water Surface, Sky Field
        if user.pbCanRaiseStatStage?(:SPEED,user,self)
          user.pbRaiseStatStage(:SPEED,1,user)
        end
      when 6 # Performance Stage
        if user.pbCanRaiseStatStage?(:ACCURACY,user,self)
          user.pbRaiseStatStage(:ACCURACY,1,user)
        end
      when 30,40 # Mirror Arena, Haunted Field
        if user.pbCanRaiseStatStage?(:EVASION,user,self)
          user.pbRaiseStatStage(:EVASION,1,user)
        end
      when 5,14,27,32,44 # Chess Board, Rocky Field, Mountain, Dragon's Den, Indoors
        target.pbFlinch(user)
      when 24,36,37 # Glitch Field, Inverse Field, Psychic Terrain
        target.pbConfuse if target.pbCanConfuse?(user,false,self)
      when 9,19 # Rainbow Field, Wasteland
        target.pbCheckAndInflictRandomStatus(user,false,self)
      end
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      id = :TACKLE   # Environment-specific anim
      case $fefieldeffect
      when 1  then id = :SHOCKWAVE
      when 2  then id = :SOLARBEAM
      when 3  then id = :MISTBALL
      when 4  then id = :DARKPULSE
      when 5  then id = :FEINT
      when 6  then id = :HYPERVOICE
      when 7  then id = :LAVAPLUME
      when 8  then id = :MUDDYWATER
      when 9  then id = :AURORABEAM
      when 10 then id = :ACID
      when 11 then id = :ACIDSPRAY
      when 12 then id = :SCORCHINGSANDS
      when 13 then id = :ICESHARD
      when 14 then id = :ROCKBLAST
      when 15 then id = :WOODHAMMER
      when 16 then id = :FLAMEBURST
      when 17 then id = :MAGNETBOMB
      when 18 then id = :ELECTROBALL
      when 19 then id = :GUNKSHOT
      when 20 then id = :SANDTOMB
      when 21 then id = :AQUAJET
      when 22 then id = :AQUATAIL
      when 23 then id = :ROCKWRECKER
      when 24 then id = :TECHNOBLAST
      when 25 then id = :POWERGEM
      when 26 then id = :SLUDGEBOMB
      when 27 then id = :ROCKBLAST
      when 28 then id = :ICEBALL
      when 29 then id = :DAZZLINGGLEAM
      when 30 then id = :MIRRORSHOT
      when 31 then id = :SLASH
      when 32 then id = :DRAGONPULSE
      when 33
        if $fecounter == 4
          id == :PETALDANCE
        elsif $fecounter > 1
          id == :PETALBLIZZARD
        else
          id == :SWEETSCENT
        end
      when 34 then id = :SWIFT
      when 35 then id = :ROAROFTIME
      when 36 then id = :CONFUSION
      when 37 then id = :PSYCHIC
      when 38 then id = :DARKPULSE
      when 39 then id = :ICEBEAM
      when 40 then id = :SHADOWBALL
      when 41 then id = :SLUDGEWAVE
      when 42 then id = :BRANCHPOKE
      when 43 then id = :SKYATTACK
      when 44 then id = :TRIATTACK
      when 45 then id = :MEGAPUNCH
      when 46 then id = :SHEERCOLD
      when 47 then id = :BUGBUZZ
      when 48 then id = :PSYCHIC
      when 49 then id = :SURF
      end
      super
    end
  end
  
  
  
  #===============================================================================
  # Able to hit semi-invulnerable targets. Never misses. (Feint Attack, Shock Wave,
  # Disarming Voice, Aura Sphere, Vital Throw, Aerial Ace, Shadow Punch, Magical Leaf,
  # Swift, Smart Strike, Magnet Bomb)
  #===============================================================================
  class PokeBattle_Move_0A5 < PokeBattle_Move
    # The point of this effect rather than just making base accuracy 0 is to allow hits to semi-invulnerable targets
    def pbAccuracyCheck(user,target); return true; end
    
    def physicalMove?(thisType=nil)
      if @id == :SMARTSTRIKE && $fefieldeffect == 37
        return false
      end
      return super
    end
    
    def specialMove?(thisType=nil)
      if @id == :SMARTSTRIKE && $fefieldeffect == 37
        return true
      end
      return super
    end
  end
  
  
  
  #===============================================================================
  # User's attack next round against the target will definitely hit.
  # (Lock-On, Mind Reader)
  #===============================================================================
  class PokeBattle_Move_0A6 < PokeBattle_Move
    def pbEffectAgainstTarget(user,target)
      user.effects[PBEffects::LockOn]    = 2
      user.effects[PBEffects::LockOnPos] = target.index
      @battle.pbDisplay(_INTL("{1} took aim at {2}!",user.pbThis,target.pbThis(true)))
      if $fefieldeffect == 30
        user.effects[PBEffects::LaserFocus] = 2
        @battle.pbDisplay(_INTL("{1} concentrated intensely!",user.pbThis))
      elsif $fefieldeffect == 37 && @id == :MINDREADER
        user.pbRaiseStatStage(:SPECIAL_ATTACK,2,user)
      end
    end
  end
  
  
  
  #===============================================================================
  # Target's evasion stat changes are ignored from now on. (Foresight, Odor Sleuth)
  # Normal and Fighting moves have normal effectiveness against the Ghost-type target.
  #===============================================================================
  class PokeBattle_Move_0A7 < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbEffectAgainstTarget(user,target)
      target.effects[PBEffects::Foresight] = true
      @battle.pbDisplay(_INTL("{1} was identified!",target.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # Target's evasion stat changes are ignored from now on. (Miracle Eye)
  # Psychic moves have normal effectiveness against the Dark-type target.
  #===============================================================================
  class PokeBattle_Move_0A8 < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbEffectAgainstTarget(user,target)
      target.effects[PBEffects::MiracleEye] = true
      @battle.pbDisplay(_INTL("{1} was identified!",target.pbThis))
      if [29,31,37].include?($fefieldeffect)
        user.pbRaiseStatStage(:SPECIAL_ATTACK,2,user)
      end
    end
  end
  
  
  
  #===============================================================================
  # This move ignores target's Defense, Special Defense and evasion stat changes.
  # (Chip Away, Darkest Lariat, Sacred Sword)
  #===============================================================================
  class PokeBattle_Move_0A9 < PokeBattle_Move
    def pbCalcAccuracyMultipliers(user,target,multipliers)
      super
      modifiers[:evasion_stage] = 0
    end
  
    def pbGetDefenseStats(user,target)
      ret1, _ret2 = super
      return ret1, 6   # Def/SpDef stat stage
    end
  end
  
  
  
  #===============================================================================
  # User is protected against moves with the "B" flag this round. (Detect, Protect)
  #===============================================================================
  class PokeBattle_Move_0AA < PokeBattle_ProtectMove
    def initialize(battle,move)
      super
      @effect = PBEffects::Protect
    end
    
    def pbEffectGeneral(user)
      super
      if @id == :DETECT && [5,20].include?($fefieldeffect)
        user.pbRaiseStatStage(:ACCURACY,1,user)
      end
    end
  end
  
  
  
  #===============================================================================
  # User's side is protected against moves with priority greater than 0 this round.
  # (Quick Guard)
  #===============================================================================
  class PokeBattle_Move_0AB < PokeBattle_ProtectMove
    def initialize(battle,move)
      super
      @effect      = PBEffects::QuickGuard
      @sidedEffect = true
    end
  end
  
  
  
  #===============================================================================
  # User's side is protected against moves that target multiple battlers this round.
  # (Wide Guard)
  #===============================================================================
  class PokeBattle_Move_0AC < PokeBattle_ProtectMove
    def initialize(battle,move)
      super
      @effect      = PBEffects::WideGuard
      @sidedEffect = true
    end
    
    def pbEffectGeneral(user)
      super
      if $fefieldeffect == 14
        user.eachAlly do |b|
          b.pbRaiseStatStage(:DEFENSE,1,user)
        end
      end
    end
  end
  
  
  
  #===============================================================================
  # Ends target's protections immediately. (Feint)
  #===============================================================================
  class PokeBattle_Move_0AD < PokeBattle_Move
    def pbEffectAgainstTarget(user,target)
      target.effects[PBEffects::BanefulBunker]          = false
      target.effects[PBEffects::KingsShield]            = false
      target.effects[PBEffects::Obstruct]               = false
      target.effects[PBEffects::Protect]                = false
      target.effects[PBEffects::SpikyShield]            = false
      target.pbOwnSide.effects[PBEffects::CraftyShield] = false
      target.pbOwnSide.effects[PBEffects::MatBlock]     = false
      target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
      target.pbOwnSide.effects[PBEffects::WideGuard]    = false
    end
  end
  
  
  
  #===============================================================================
  # Uses the last move that the target used. (Mirror Move)
  #===============================================================================
  class PokeBattle_Move_0AE < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
    def callsAnotherMove?; return true; end
  
    def pbFailsAgainstTarget?(user,target)
      if !target.lastRegularMoveUsed ||
         !GameData::Move.get(target.lastRegularMoveUsed).flags[/e/]   # Not copyable by Mirror Move
        @battle.pbDisplay(_INTL("The mirror move failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      if $fefieldeffect == 5
        user.effects[PBEffects::NeverMiss] = true
      elsif $fefieldeffect == 30
        user.pbRaiseStatStage([:ACCURACY,:ATTACK,:SPECIAL_ATTACK],1,user)
      elsif $fefieldeffect == 43
        user.pbRaiseStatStage([:ATTACK,:SPEED],1,user)
      elsif $fefieldeffect == 45
        user.pbRaiseStatStage(:SPEED,1,user)
      end
      user.pbUseMoveSimple(target.lastRegularMoveUsed,target.index)
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      # No animation
    end
  end
  
  
  
  #===============================================================================
  # Uses the last move that was used. (Copycat)
  #===============================================================================
  class PokeBattle_Move_0AF < PokeBattle_Move
    def callsAnotherMove?; return true; end
  
    def initialize(battle,move)
      super
      @moveBlacklist = [
         # Struggle, Chatter, Belch
         "002",   # Struggle
         "014",   # Chatter
         "158",   # Belch                               # Not listed on Bulbapedia
         # Moves that affect the moveset
         "05C",   # Mimic
         "05D",   # Sketch
         "069",   # Transform
         # Counter moves
         "071",   # Counter
         "072",   # Mirror Coat
         "073",   # Metal Burst                         # Not listed on Bulbapedia
         # Helping Hand, Feint (always blacklisted together, don't know why)
         "09C",   # Helping Hand
         "0AD",   # Feint
         # Protection moves
         "0AA",   # Detect, Protect
         "0AB",   # Quick Guard                         # Not listed on Bulbapedia
         "0AC",   # Wide Guard                          # Not listed on Bulbapedia
         "0E8",   # Endure
         "149",   # Mat Block
         "14A",   # Crafty Shield                       # Not listed on Bulbapedia
         "14B",   # King's Shield
         "14C",   # Spiky Shield
         "168",   # Baneful Bunker
         "180",   # Obstruct
         # Moves that call other moves
         "0AE",   # Mirror Move
         "0AF",   # Copycat (this move)
         "0B0",   # Me First
         "0B3",   # Nature Power                        # Not listed on Bulbapedia
         "0B4",   # Sleep Talk
         "0B5",   # Assist
         "0B6",   # Metronome
         # Move-redirecting and stealing moves
         "0B1",   # Magic Coat                          # Not listed on Bulbapedia
         "0B2",   # Snatch
         "117",   # Follow Me, Rage Powder
         "16A",   # Spotlight
         # Set up effects that trigger upon KO
         "0E6",   # Grudge                              # Not listed on Bulbapedia
         "0E7",   # Destiny Bond
         # Held item-moving moves
         "0F1",   # Covet, Thief
         "0F2",   # Switcheroo, Trick
         "0F3",   # Bestow
         # Moves that start focussing at the start of the round
         "115",   # Focus Punch
         "171",   # Shell Trap
         "172",   # Beak Blast
         # Event moves that do nothing
         "133",   # Hold Hands
         "134"    # Celebrate
      ]
      if Settings::MECHANICS_GENERATION >= 6
        @moveBlacklist += [
           # Target-switching moves
           "0EB",   # Roar, Whirlwind
           "0EC"    # Circle Throw, Dragon Tail
        ]
      end
    end
  
    def pbChangeUsageCounters(user,specialUsage)
      super
      @copied_move = @battle.lastMoveUsed
    end
  
    def pbMoveFailed?(user,targets)
      if !@copied_move || GameData::Move.get(@copied_move).zMove? ||
         @moveBlacklist.include?(GameData::Move.get(@copied_move).function_code)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      if $fefieldeffect == 30
        user.pbRaiseStatStage([:ATTACK,:SPECIAL_ATTACK,:EVASION],1,user)
      end
      user.pbUseMoveSimple(@copied_move)
    end
  end
  
  
  
  #===============================================================================
  # Uses the move the target was about to use this round, with 1.5x power.
  # (Me First)
  #===============================================================================
  class PokeBattle_Move_0B0 < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
    def callsAnotherMove?; return true; end
  
    def initialize(battle,move)
      super
      @moveBlacklist = [
         "0F1",   # Covet, Thief
         # Struggle, Chatter, Belch
         "002",   # Struggle
         "014",   # Chatter
         "158",   # Belch
         # Counter moves
         "071",   # Counter
         "072",   # Mirror Coat
         "073",   # Metal Burst
         # Moves that start focussing at the start of the round
         "115",   # Focus Punch
         "171",   # Shell Trap
         "172"    # Beak Blast
      ]
    end
  
    def pbFailsAgainstTarget?(user,target)
      return true if pbMoveFailedTargetAlreadyMoved?(target)
      oppMove = @battle.choices[target.index][2]
      if !oppMove || oppMove.statusMove? || @moveBlacklist.include?(oppMove.function) || oppMove.powerMove?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      user.effects[PBEffects::MeFirst] = true
      user.pbUseMoveSimple(@battle.choices[target.index][2].id)
      user.effects[PBEffects::MeFirst] = false
      if $fefieldeffect == 31
        user.pbRaiseStatStage([:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED],1,user)
      end
    end
  end
  
  
  
  #===============================================================================
  # This round, reflects all moves with the "C" flag targeting the user back at
  # their origin. (Magic Coat)
  #===============================================================================
  class PokeBattle_Move_0B1 < PokeBattle_Move
    def pbEffectGeneral(user)
      user.effects[PBEffects::MagicCoat] = true
      @battle.pbDisplay(_INTL("{1} shrouded itself with Magic Coat!",user.pbThis))
      if [4,25].include?($fefieldeffect)
        user.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user)
      end
    end
  end
  
  
  
  #===============================================================================
  # This round, snatches all used moves with the "D" flag. (Snatch)
  #===============================================================================
  class PokeBattle_Move_0B2 < PokeBattle_Move
    def pbEffectGeneral(user)
      user.effects[PBEffects::Snatch] = 1
      @battle.eachBattler do |b|
        next if b.effects[PBEffects::Snatch]<user.effects[PBEffects::Snatch]
        user.effects[PBEffects::Snatch] = b.effects[PBEffects::Snatch]+1
      end
      @battle.pbDisplay(_INTL("{1} waits for a target to make a move!",user.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # Uses a different move depending on the environment. (Nature Power)
  # NOTE: This code does not support the Gen 5 and older definition of the move
  #       where it targets the user. It makes more sense for it to target another
  #       Pokémon.
  #===============================================================================
  class PokeBattle_Move_0B3 < PokeBattle_Move
    def callsAnotherMove?; return true; end
      
    def pbMoveFailed?(user,targets)
      if $fefieldeffect == 0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbOnStartUse(user,targets)
      case $fefieldeffect
      when 1 then @npMove = :RISINGVOLTAGE
      when 2 then @npMove = :GRASSKNOT
      when 3 then @npMove = :MISTBALL
      when 4 then @npMove = :PRISMATICLASER
      when 5 then @npMove = :COURTCHANGE
      when 6 then @npMove = :ACROBATICS
      when 7 then @npMove = :MAGMASTORM
      when 8 then @npMove = :MUDDYWATER
      when 9 then @npMove = :AURORABEAM
      when 10 then @npMove = :ACID
      when 11 then @npMove = :CORROSIVEGAS
      when 12 then @npMove = :SCORCHINGSANDS
      when 13 then @npMove = :ICICLECRASH
      when 14 then @npMove = :STONEEDGE
      when 15 then @npMove = :BRANCHPOKE
      when 16 then @npMove = :ERUPTION
      when 17 then @npMove = :GEARGRIND
      when 18 then @npMove = :EERIEIMPULSE
      when 19 then @npMove = :TRASHALANCHE
      when 20 then @npMove = :DUSTSTORM
      when 21 then @npMove = :SPLASH
      when 22 then @npMove = :FLIPTURN
      when 23 then @npMove = :ROCKTOMB
      when 24 then @npMove = :METRONOME
      when 25 then @npMove = :POWERGEM
      when 26 then @npMove = :SLUDGEWAVE
      when 27 then @npMove = :ROCKSLIDE
      when 28 then @npMove = :AVALANCHE
      when 29 then @npMove = :JUDGMENT
      when 30 then @npMove = :MIRRORLAUNCH
      when 31 then @npMove = :DRAININGKISS
      when 32 then @npMove = :DRACONICDISASTER
      when 33
        if $fecounter == 4
          @npMove = :PETALBLIZZARD
        else
          @npMove = :GROWTH
        end
      when 34 then @npMove = :WISH
      when 35 then @npMove = :SPACIALREND
      when 36 then @npMove = :TRICKROOM
      when 37 then @npMove = :PSYWAVE
      when 38 then @npMove = :DARKVOID
      when 39 then @npMove = :PUNISHMENT
      when 40 then @npMove = :POLTERGEIST
      when 41 then @npMove = :SLUDGE
      when 42 then @npMove = :MAGICALLEAF
      when 43 then @npMove = :SKYATTACK
      when 44 then @npMove = :TEATIME
      when 45 then @npMove = :SUBMISSION
      when 46 then @npMove = :GLACIATE
      when 47 then @npMove = :JUNGLEHEALING
      when 48 then @npMove = :TSUNAMI
      when 49 then @npMove = :NEEDLEARM
      end
    end
  
    def pbEffectAgainstTarget(user,target)
      @battle.pbDisplay(_INTL("{1} turned into {2}!", @name, GameData::Move.get(@npMove).name))
      user.pbUseMoveSimple(@npMove,target.index)
    end
  end
  
  
  
  #===============================================================================
  # Uses a random move the user knows. Fails if user is not asleep. (Sleep Talk)
  #===============================================================================
  class PokeBattle_Move_0B4 < PokeBattle_Move
    def usableWhenAsleep?; return true; end
    def callsAnotherMove?; return true; end
  
    def initialize(battle,move)
      super
      @moveBlacklist = [
         "0D1",   # Uproar
         "0D4",   # Bide
         # Struggle, Chatter, Belch
         "002",   # Struggle                            # Not listed on Bulbapedia
         "014",   # Chatter                             # Not listed on Bulbapedia
         "158",   # Belch
         # Moves that affect the moveset (except Transform)
         "05C",   # Mimic
         "05D",   # Sketch
         # Moves that call other moves
         "0AE",   # Mirror Move
         "0AF",   # Copycat
         "0B0",   # Me First
         "0B3",   # Nature Power                        # Not listed on Bulbapedia
         "0B4",   # Sleep Talk
         "0B5",   # Assist
         "0B6",   # Metronome
         # Two-turn attacks
         "0C3",   # Razor Wind
         "0C4",   # Solar Beam, Solar Blade
         "0C5",   # Freeze Shock
         "0C6",   # Ice Burn
         "0C7",   # Sky Attack
         "0C8",   # Skull Bash
         "0C9",   # Fly
         "0CA",   # Dig
         "0CB",   # Dive
         "0CC",   # Bounce
         "0CD",   # Shadow Force
         "0CE",   # Sky Drop
         "12E",   # Shadow Half
         "14D",   # Phantom Force
         "14E",   # Geomancy
         # Moves that start focussing at the start of the round
         "115",   # Focus Punch
         "171",   # Shell Trap
         "172"    # Beak Blast
      ]
    end
  
    def pbMoveFailed?(user,targets)
      @sleepTalkMoves = []
      user.eachMoveWithIndex do |m,i|
        next if @moveBlacklist.include?(m.function)
        next if !@battle.pbCanChooseMove?(user.index,i,false,true)
        @sleepTalkMoves.push(i)
      end
      if !user.asleep? || @sleepTalkMoves.length==0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      choice = @sleepTalkMoves[@battle.pbRandom(@sleepTalkMoves.length)]
      user.pbUseMoveSimple(user.moves[choice].id,user.pbDirectOpposing.index, choice)
    end
  end
  
  
  
  #===============================================================================
  # Uses a random move known by any non-user Pokémon in the user's party. (Assist)
  #===============================================================================
  class PokeBattle_Move_0B5 < PokeBattle_Move
    def callsAnotherMove?; return true; end
  
    def initialize(battle,move)
      super
      @moveBlacklist = [
         # Struggle, Chatter, Belch
         "002",   # Struggle
         "014",   # Chatter
         "158",   # Belch
         # Moves that affect the moveset
         "05C",   # Mimic
         "05D",   # Sketch
         "069",   # Transform
         # Counter moves
         "071",   # Counter
         "072",   # Mirror Coat
         "073",   # Metal Burst                         # Not listed on Bulbapedia
         # Helping Hand, Feint (always blacklisted together, don't know why)
         "09C",   # Helping Hand
         "0AD",   # Feint
         # Protection moves
         "0AA",   # Detect, Protect
         "0AB",   # Quick Guard                         # Not listed on Bulbapedia
         "0AC",   # Wide Guard                          # Not listed on Bulbapedia
         "0E8",   # Endure
         "149",   # Mat Block
         "14A",   # Crafty Shield                       # Not listed on Bulbapedia
         "14B",   # King's Shield
         "14C",   # Spiky Shield
         "168",   # Baneful Bunker
         "180",   # Obstruct
         # Moves that call other moves
         "0AE",   # Mirror Move
         "0AF",   # Copycat
         "0B0",   # Me First
  #       "0B3",   # Nature Power                                      # See below
         "0B4",   # Sleep Talk
         "0B5",   # Assist
         "0B6",   # Metronome
         # Move-redirecting and stealing moves
         "0B1",   # Magic Coat                          # Not listed on Bulbapedia
         "0B2",   # Snatch
         "117",   # Follow Me, Rage Powder
         "16A",   # Spotlight
         # Set up effects that trigger upon KO
         "0E6",   # Grudge                              # Not listed on Bulbapedia
         "0E7",   # Destiny Bond
         # Target-switching moves
  #       "0EB",   # Roar, Whirlwind                                    # See below
         "0EC",   # Circle Throw, Dragon Tail
         # Held item-moving moves
         "0F1",   # Covet, Thief
         "0F2",   # Switcheroo, Trick
         "0F3",   # Bestow
         # Moves that start focussing at the start of the round
         "115",   # Focus Punch
         "171",   # Shell Trap
         "172",   # Beak Blast
         # Event moves that do nothing
         "133",   # Hold Hands
         "134"    # Celebrate
      ]
      if Settings::MECHANICS_GENERATION >= 6
        @moveBlacklist += [
           # Moves that call other moves
           "0B3",   # Nature Power
           # Two-turn attacks
           "0C3",   # Razor Wind                        # Not listed on Bulbapedia
           "0C4",   # Solar Beam, Solar Blade           # Not listed on Bulbapedia
           "0C5",   # Freeze Shock                      # Not listed on Bulbapedia
           "0C6",   # Ice Burn                          # Not listed on Bulbapedia
           "0C7",   # Sky Attack                        # Not listed on Bulbapedia
           "0C8",   # Skull Bash                        # Not listed on Bulbapedia
           "0C9",   # Fly
           "0CA",   # Dig
           "0CB",   # Dive
           "0CC",   # Bounce
           "0CD",   # Shadow Force
           "0CE",   # Sky Drop
           "12E",   # Shadow Half
           "14D",   # Phantom Force
           "14E",   # Geomancy                          # Not listed on Bulbapedia
           # Target-switching moves
           "0EB"    # Roar, Whirlwind
        ]
      end
    end
  
    def pbMoveFailed?(user,targets)
      @assistMoves = []
      @battle.pbParty(user.index).each_with_index do |pkmn,i|
        next if !pkmn || i==user.pokemonIndex
        next if Settings::MECHANICS_GENERATION >= 6 && pkmn.egg?
        pkmn.moves.each do |move|
          next if move.powerMove?
          next if @moveBlacklist.include?(move.function_code)
          next if move.types.include?(:SHADOW)
          @assistMoves.push(move.id)
        end
      end
      if @assistMoves.length==0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      move = @assistMoves[@battle.pbRandom(@assistMoves.length)]
      user.pbUseMoveSimple(move)
    end
  end
  
  
  
  #===============================================================================
  # Uses a random move that exists. (Metronome)
  #===============================================================================
  class PokeBattle_Move_0B6 < PokeBattle_Move
    def callsAnotherMove?; return true; end
  
    def initialize(battle,move)
      super
      @moveBlacklist = [
         "011",   # Snore
         "11D",   # After You
         "11E",   # Quash
         "16C",   # Instruct
         # Struggle, Chatter, Belch
         "002",   # Struggle
         "014",   # Chatter
         "158",   # Belch
         # Moves that affect the moveset
         "05C",   # Mimic
         "05D",   # Sketch
         "069",   # Transform
         # Counter moves
         "071",   # Counter
         "072",   # Mirror Coat
         "073",   # Metal Burst                         # Not listed on Bulbapedia
         # Helping Hand, Feint (always blacklisted together, don't know why)
         "09C",   # Helping Hand
         "0AD",   # Feint
         # Protection moves
         "0AA",   # Detect, Protect
         "0AB",   # Quick Guard
         "0AC",   # Wide Guard
         "0E8",   # Endure
         "149",   # Mat Block
         "14A",   # Crafty Shield
         "14B",   # King's Shield
         "14C",   # Spiky Shield
         "168",   # Baneful Bunker
         "180",   # Obstruct
         # Moves that call other moves
         "0AE",   # Mirror Move
         "0AF",   # Copycat
         "0B0",   # Me First
         "0B3",   # Nature Power
         "0B4",   # Sleep Talk
         "0B5",   # Assist
         "0B6",   # Metronome
         # Move-redirecting and stealing moves
         "0B1",   # Magic Coat                          # Not listed on Bulbapedia
         "0B2",   # Snatch
         "117",   # Follow Me, Rage Powder
         "16A",   # Spotlight
         # Set up effects that trigger upon KO
         "0E6",   # Grudge                              # Not listed on Bulbapedia
         "0E7",   # Destiny Bond
         # Held item-moving moves
         "0F1",   # Covet, Thief
         "0F2",   # Switcheroo, Trick
         "0F3",   # Bestow
         # Moves that start focussing at the start of the round
         "115",   # Focus Punch
         "171",   # Shell Trap
         "172",   # Beak Blast
         # Event moves that do nothing
         "133",   # Hold Hands
         "134"    # Celebrate
      ]
      @moveBlacklistSignatures = [
         #:SNARL,
         # Signature moves
         #:DIAMONDSTORM,     # Diancie (Gen 6)
         #:FLEURCANNON,      # Magearna (Gen 7)
         #:FREEZESHOCK,      # Black Kyurem (Gen 5)
         :HYPERSPACEFURY#,   # Hoopa Unbound (Gen 6)
         #:HYPERSPACEHOLE,   # Hoopa Confined (Gen 6)
         #:ICEBURN,          # White Kyurem (Gen 5)
         #:LIGHTOFRUIN,      # Eternal Flower Floette (Gen 6)
         #:MINDBLOWN,        # Blacephalon (Gen 7)
         #:PHOTONGEYSER,     # Necrozma (Gen 7)
         #:PLASMAFISTS,      # Zeraora (Gen 7)
         #:RELICSONG,        # Meloetta (Gen 5)
         #:SECRETSWORD,      # Keldeo (Gen 5)
         #:SPECTRALTHIEF,    # Marshadow (Gen 7)
         #:STEAMERUPTION,    # Volcanion (Gen 6)
         #:TECHNOBLAST,      # Genesect (Gen 5)
         #:THOUSANDARROWS,   # Zygarde (Gen 6)
         #:THOUSANDWAVES,    # Zygarde (Gen 6)
         #:VCREATE           # Victini (Gen 5)
      ]
    end
  
    def pbMoveFailed?(user,targets)
      @metronomeMove = []
      move_keys = GameData::Move::DATA.keys#.sort
      usages = 1
      if $fefieldeffect == 6
        usages += user.stages[:SPEED]
      end
      while usages>0
        1000.times do
          move_id = move_keys[@battle.pbRandom(move_keys.length)]
          move_data = GameData::Move.get(move_id)
          next if move_data.powerMove?
          next if @moveBlacklist.include?(move_data.function_code)
          next if @moveBlacklistSignatures.include?(move_data.id)
          next if move_data.type == :SHADOW
          next if $fefieldeffect == 9 && !user.pbHasType?(move_data.type)
          next if $fefieldeffect == 24 && move_data.base_damage < 70
          @metronomeMove.push(move_data.id)
          usages -= 1
          break
        end
      end
      if @metronomeMove == []
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      for m in @metronomeMove
        user.pbUseMoveSimple(m)
      end
    end
  end
  
  
  
  #===============================================================================
  # The target can no longer use the same move twice in a row. (Torment)
  #===============================================================================
  class PokeBattle_Move_0B7 < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbFailsAgainstTarget?(user,target)
      if target.effects[PBEffects::Torment]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return true if pbMoveFailedAromaVeil?(user,target)
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.effects[PBEffects::Torment] = true
      @battle.pbDisplay(_INTL("{1} was subjected to torment!",target.pbThis))
      target.pbItemStatusCureCheck
      if $fefieldeffect == 39
        target.effects[PBEffects::MeanLook] = user.index
        @battle.pbDisplay(_INTL("{1} can no longer escape!",target.pbThis))
      end
    end
  end
  
  
  
  #===============================================================================
  # Disables all target's moves that the user also knows. (Imprison)
  #===============================================================================
  class PokeBattle_Move_0B8 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if user.effects[PBEffects::Imprison]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.effects[PBEffects::Imprison] = true
      @battle.pbDisplay(_INTL("{1} sealed any moves its target shares with it!",user.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # For 5 rounds, disables the last move the target used. (Disable)
  #===============================================================================
  class PokeBattle_Move_0B9 < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbFailsAgainstTarget?(user,target)
      if target.effects[PBEffects::Disable]>0 || !target.lastRegularMoveUsed
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return true if pbMoveFailedAromaVeil?(user,target)
      canDisable = false
      target.eachMove do |m|
        next if m.id!=target.lastRegularMoveUsed
        next if m.pp==0 && m.total_pp>0
        canDisable = true
        break
      end
      if !canDisable
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      if $fefieldeffect == 42
        target.effects[PBEffects::Disable] = 8
      else
        target.effects[PBEffects::Disable] = 5
      end
      target.effects[PBEffects::DisableMove] = target.lastRegularMoveUsed
      @battle.pbDisplay(_INTL("{1}'s {2} was disabled!",target.pbThis,
         GameData::Move.get(target.lastRegularMoveUsed).name))
      target.pbItemStatusCureCheck
    end
  end
  
  
  
  #===============================================================================
  # For 4 rounds, disables the target's non-damaging moves. (Taunt)
  #===============================================================================
  class PokeBattle_Move_0BA < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbFailsAgainstTarget?(user,target)
      if target.effects[PBEffects::Taunt]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return true if pbMoveFailedAromaVeil?(user,target)
      if Settings::MECHANICS_GENERATION >= 6 && (target.hasActiveAbility?(:OBLIVIOUS) ||
         target.hasActiveAbility?(:SOUNDPROOF) && $fefieldeffect == 6) && !@battle.moldBreaker
        @battle.pbShowAbilitySplash(target)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("But it failed!"))
        else
          @battle.pbDisplay(_INTL("But it failed because of {1}'s {2}!",
             target.pbThis(true),target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      if [4,6,32].include?($fefieldeffect)
        target.effects[PBEffects::Taunt] = 6
      else
        target.effects[PBEffects::Taunt] = 4
      end
      @battle.pbDisplay(_INTL("{1} fell for the taunt!",target.pbThis))
      target.pbItemStatusCureCheck
      if $fefieldeffect == 39
        target.effects[PBEffects::MeanLook] = user.index
        @battle.pbDisplay(_INTL("{1} can no longer escape!",target.pbThis))
      end
    end
  end
  
  
  
  #===============================================================================
  # For 5 rounds, disables the target's healing moves. (Heal Block)
  #===============================================================================
  class PokeBattle_Move_0BB < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      if target.effects[PBEffects::HealBlock]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return true if pbMoveFailedAromaVeil?(user,target)
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      if $fefieldeffect == 42
        target.effects[PBEffects::HealBlock] = 8
      else
        target.effects[PBEffects::HealBlock] = 5
      end
      @battle.pbDisplay(_INTL("{1} was prevented from healing!",target.pbThis))
      target.pbItemStatusCureCheck
    end
  end
  
  
  
  #===============================================================================
  # For 4 rounds, the target must use the same move each round. (Encore)
  #===============================================================================
  class PokeBattle_Move_0BC < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def initialize(battle,move)
      super
      @moveBlacklist = [
         "0BC",   # Encore
         # Struggle
         "002",   # Struggle
         # Moves that affect the moveset
         "05C",   # Mimic
         "05D",   # Sketch
         "069",   # Transform
         # Moves that call other moves (see also below)
         "0AE"    # Mirror Move
      ]
      if Settings::MECHANICS_GENERATION >= 7
        @moveBlacklist += [
           # Moves that call other moves
  #         "0AE",   # Mirror Move                                     # See above
           "0AF",   # Copycat
           "0B0",   # Me First
           "0B3",   # Nature Power
           "0B4",   # Sleep Talk
           "0B5",   # Assist
           "0B6"    # Metronome
        ]
      end
    end
  
    def pbFailsAgainstTarget?(user,target)
      if target.effects[PBEffects::Encore]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if !target.lastRegularMoveUsed ||
         @moveBlacklist.include?(GameData::Move.get(target.lastRegularMoveUsed).function_code)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if target.effects[PBEffects::ShellTrap]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if target.lastMoveUsedIsZMove
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return true if pbMoveFailedAromaVeil?(user,target)
      canEncore = false
      target.eachMove do |m|
        next if m.id!=target.lastRegularMoveUsed
        next if m.pp==0 && m.total_pp>0
        canEncore = true
        break
      end
      if !canEncore
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      if [6,45].include?($fefieldeffect)
        target.effects[PBEffects::Encore] = 7
      else
        target.effects[PBEffects::Encore] = 4
      end
      target.effects[PBEffects::EncoreMove] = target.lastRegularMoveUsed
      @battle.pbDisplay(_INTL("{1} received an encore!",target.pbThis))
      target.pbItemStatusCureCheck
    end
  end
  
  
  
  #===============================================================================
  # Hits twice.
  #===============================================================================
  class PokeBattle_Move_0BD < PokeBattle_Move
    def multiHitMove?;           return true; end
    def pbNumHits(user,targets); return 2;    end
  end
  
  
  
  #===============================================================================
  # Hits twice. May poison the target on each hit. (Twineedle)
  #===============================================================================
  class PokeBattle_Move_0BE < PokeBattle_PoisonMove
    def multiHitMove?;           return true; end
    def pbNumHits(user,targets); return 2;    end
  end
  
  
  
  #===============================================================================
  # Hits 3 times. Power is multiplied by the hit number. (Triple Kick, Triple Axel)
  # An accuracy check is performed for each hit.
  #===============================================================================
  class PokeBattle_Move_0BF < PokeBattle_Move
    def multiHitMove?;           return true; end
    def pbNumHits(user,targets); return 3;    end
  
    def successCheckPerHit?
      return @accCheckPerHit
    end
  
    def pbOnStartUse(user,targets)
      @calcBaseDmg = 0
      @accCheckPerHit = !(user.hasActiveAbility?(:SKILLLINK) && $fefieldeffect != 37)
    end
  
    def pbBaseDamage(baseDmg,user,target)
      @calcBaseDmg += baseDmg if !target.damageState.disguise && !target.damageState.iceface
      return @calcBaseDmg
    end
  end
  
  
  
  #===============================================================================
  # Hits 2-5 times.
  #===============================================================================
  class PokeBattle_Move_0C0 < PokeBattle_Move
    def multiHitMove?; return true; end
  
    def pbNumHits(user,targets)
      if @id == :WATERSHURIKEN && user.hasActiveAbility?(:BATTLEBOND) #&& user.form == 2 && user.isSpecies?(:GRENINJA)
        return 3
      end
      hitChances = [2,2,3,3,4,5]
      r = @battle.pbRandom(hitChances.length)
      r = hitChances.length-1 if user.hasActiveAbility?(:SKILLLINK) && $fefieldeffect != 37
      return hitChances[r]
    end
  
    def pbBaseDamage(baseDmg,user,target)
      if @id == :WATERSHURIKEN && user.hasActiveAbility?(:BATTLEBOND) #user.form == 2 && user.isSpecies?(:GRENINJA)
        return 20
      end
      return super
    end
  end
  
  
  
  #===============================================================================
  # Hits X times, where X is the number of non-user unfainted status-free Pokémon
  # in the user's party (not including partner trainers). Fails if X is 0.
  # Base power of each hit depends on the base Attack stat for the species of that
  # hit's participant. (Beat Up)
  #===============================================================================
  class PokeBattle_Move_0C1 < PokeBattle_Move
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
      atk = @battle.pbParty(user.index)[i].baseStats[:ATTACK]
      return 5+(atk/10)
    end
  end
  
  
  
  #===============================================================================
  # Two turn attack. Attacks first turn, skips second turn (if successful).
  #===============================================================================
  class PokeBattle_Move_0C2 < PokeBattle_Move
    def pbEffectGeneral(user)
      return if user.hasActiveAbility?(:ATTENTIVE) && $fefieldeffect != 37 || $fefieldeffect == 16 && 
                @id == :BLASTBURN
      user.effects[PBEffects::HyperBeam] = 2
      user.currentMove = @id
    end
  end
  
  
  
  #===============================================================================
  # Two turn attack. Skips first turn, attacks second turn. (Razor Wind)
  #===============================================================================
  class PokeBattle_Move_0C3 < PokeBattle_TwoTurnMove
    def pbIsChargingTurn?(user)
      ret = super
      if !user.effects[PBEffects::TwoTurnAttack]
        if $fefieldeffect == 43
          @powerHerb = false
          @chargingTurn = true
          @damagingTurn = true
        end
      end
      return ret
    end
    
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} whipped up a whirlwind!",user.pbThis))
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      if @chargingTurn# && !@damagingTurn # Charging anim
        @battle.pbCommonAnimation("Razor Wind charging",user)
        @chargingTurn = false
      else
        super
      end
    end
  end
  
  
  
  #===============================================================================
  # Two turn attack. Skips first turn, attacks second turn. (Solar Beam, Solar Blade)
  # Power halved in all weather except sunshine. In sunshine, takes 1 turn instead.
  #===============================================================================
  class PokeBattle_Move_0C4 < PokeBattle_TwoTurnMove
    def pbIsChargingTurn?(user)
      ret = super
      if !user.effects[PBEffects::TwoTurnAttack]
        if [:Sun, :HarshSun].include?(@battle.pbWeather) && !user.hasUtilityUmbrella? ||
           [9,12,34,43,49].include?($fefieldeffect)
          @powerHerb = false
          @chargingTurn = true
          @damagingTurn = true
        end
      end
      return ret
    end
  
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} took in sunlight!",user.pbThis))
    end
  
    def pbBaseDamageMultiplier(damageMult,user,target)
      damageMult /= 2 if ![:None, :Sun, :HarshSun].include?(@battle.pbWeather) &&
                          !([:Rain, :HeavyRain].include?(@battle.pbWeather) && user.hasUtilityUmbrella?)
      return damageMult
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      if @chargingTurn# && !@damagingTurn # Charging anim
        @battle.pbCommonAnimation("Solar Beam charging",user)
        @chargingTurn = false
      else
        super
      end
    end
  end
  
  
  
  #===============================================================================
  # Two turn attack. Skips first turn, attacks second turn. (Freeze Shock)
  # May paralyze the target.
  #===============================================================================
  class PokeBattle_Move_0C5 < PokeBattle_TwoTurnMove
    def pbIsChargingTurn?(user)
      ret = super
      if !user.effects[PBEffects::TwoTurnAttack]
        if [39,46].include?($fefieldeffect)
          @powerHerb = false
          @chargingTurn = true
          @damagingTurn = true
        end
      end
      return ret
    end
    
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} became cloaked in a freezing light!",user.pbThis))
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      if @chargingTurn# && !@damagingTurn # Charging anim
        @battle.pbCommonAnimation("Freeze Shock charging",user)
        @chargingTurn = false
      else
        super
      end
    end
  end
  
  
  
  #===============================================================================
  # Two turn attack. Skips first turn, attacks second turn. (Ice Burn)
  # May burn the target.
  #===============================================================================
  class PokeBattle_Move_0C6 < PokeBattle_TwoTurnMove
    def pbIsChargingTurn?(user)
      ret = super
      if !user.effects[PBEffects::TwoTurnAttack]
        if [39,46].include?($fefieldeffect)
          @powerHerb = false
          @chargingTurn = true
          @damagingTurn = true
        end
      end
      return ret
    end
    
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} became cloaked in freezing air!",user.pbThis))
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      target.pbBurn(user) if target.pbCanBurn?(user,false,self)
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      if @chargingTurn# && !@damagingTurn # Charging anim
        @battle.pbCommonAnimation("Ice Burn charging",user)
        @chargingTurn = false
      else
        super
      end
    end
  end
  
  
  
  #===============================================================================
  # Two turn attack. Skips first turn, attacks second turn. (Sky Attack)
  # May make the target flinch.
  #===============================================================================
  class PokeBattle_Move_0C7 < PokeBattle_TwoTurnMove
    def flinchingMove?; return true; end
      
    def pbIsChargingTurn?(user)
      ret = super
      if !user.effects[PBEffects::TwoTurnAttack]
        if $fefieldeffect == 43 || [27,28].include?($fefieldeffect) &&
           @battle.pbWeather == :StrongWinds
          @powerHerb = false
          @chargingTurn = true
          @damagingTurn = true
        end
      end
      return ret
    end
  
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} became cloaked in a harsh light!",user.pbThis))
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      target.pbFlinch(user)
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      if @chargingTurn# && !@damagingTurn # Charging anim
        @battle.pbCommonAnimation("Sky Attack charging",user)
        @chargingTurn = false
      else
        super
      end
    end
  end
  
  
  
  #===============================================================================
  # Two turn attack. Ups user's Defense by 1 stage first turn, attacks second turn.
  # (Skull Bash)
  #===============================================================================
  class PokeBattle_Move_0C8 < PokeBattle_TwoTurnMove
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} tucked in its head!",user.pbThis))
    end
  
    def pbChargingTurnEffect(user,target)
      if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
        user.pbRaiseStatStage(:DEFENSE,1,user)
      end
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      if @chargingTurn# && !@damagingTurn # Charging anim
        @battle.pbCommonAnimation("Skull Bash charging",user)
        @chargingTurn = false
      else
        super
      end
    end
  end
  
  
  
  #===============================================================================
  # Two turn attack. Skips first turn, attacks second turn. (Fly)
  # (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
  #===============================================================================
  class PokeBattle_Move_0C9 < PokeBattle_TwoTurnMove
    def unusableInGravity?; return true; end
      
    def pbIsChargingTurn?(user)
      ret = super
      if !user.effects[PBEffects::TwoTurnAttack]
        if [13,23,41,43,44].include?($fefieldeffect)
          @powerHerb = false
          @chargingTurn = true
          @damagingTurn = true
        end
      end
      return ret
    end
  
    def pbChargingTurnMessage(user,targets)
      if $fefieldeffect == 9
        @battle.pbDisplay(_INTL("Somewhere, over the rainbow..."))
      else
        @battle.pbDisplay(_INTL("{1} flew up high!",user.pbThis))
      end
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      if @chargingTurn #&& !@damagingTurn # Charging anim
        @battle.pbCommonAnimation("Fly charging",user)
        @chargingTurn = false
      else
        super
      end
    end
  end
  
  
  
  #===============================================================================
  # Two turn attack. Skips first turn, attacks second turn. (Dig)
  # (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
  #===============================================================================
  class PokeBattle_Move_0CA < PokeBattle_TwoTurnMove
    def pbIsChargingTurn?(user)
      ret = super
      if !user.effects[PBEffects::TwoTurnAttack]
        if [12,49].include?($fefieldeffect)
          @powerHerb = false
          @chargingTurn = true
          @damagingTurn = true
        end
      end
      return ret
    end
    
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} burrowed its way under the ground!",user.pbThis))
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      if @chargingTurn# && !@damagingTurn # Charging anim
        @battle.pbCommonAnimation("Dig charging",user)
        @chargingTurn = false
      else
        super
      end
    end
  end
  
  
  
  #===============================================================================
  # Two turn attack. Skips first turn, attacks second turn. (Dive)
  # (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
  #===============================================================================
  class PokeBattle_Move_0CB < PokeBattle_TwoTurnMove
    def pbIsChargingTurn?(user)
      ret = super
      if !user.effects[PBEffects::TwoTurnAttack]
        if [21,22].include?($fefieldeffect)
          @powerHerb = false
          @chargingTurn = true
          @damagingTurn = true
        end
      end
      return ret
    end
    
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} hid underwater!",user.pbThis))
      return if !user.hasActiveAbility?(:GULPMISSILE) || #!user.isSpecies?(:CRAMORANT) ||
                user.form != 0 || $fefieldeffect == 38
      newForm = (user.hp > (user.totalhp/2)) ? 1 : 2
      user.pbChangeForm(newForm,"")
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      if @chargingTurn# && !@damagingTurn # Charging anim
        @battle.pbCommonAnimation("Dive charging",user)
        @chargingTurn = false
      else
        super
      end
    end
  end
  
  
  
  #===============================================================================
  # Two turn attack. Skips first turn, attacks second turn. (Bounce)
  # May paralyze the target.
  # (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
  #===============================================================================
  class PokeBattle_Move_0CC < PokeBattle_TwoTurnMove
    def unusableInGravity?; return true; end
  
    def pbIsChargingTurn?(user)
      ret = super
      if !user.effects[PBEffects::TwoTurnAttack]
        if [13,23,41,43,44].include?($fefieldeffect)
          @powerHerb = false
          @chargingTurn = true
          @damagingTurn = true
        end
      end
      return ret
    end
    
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} sprang up!",user.pbThis))
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      if @chargingTurn# && !@damagingTurn # Charging anim
        @battle.pbCommonAnimation("Bounce charging",user)
        @chargingTurn = false
      else
        super
      end
    end
  end
  
  
  
  #===============================================================================
  # Two turn attack. Skips first turn, attacks second turn. (Shadow Force)
  # Is invulnerable during use. Ends target's protections upon hit.
  #===============================================================================
  class PokeBattle_Move_0CD < PokeBattle_TwoTurnMove
    def pbIsChargingTurn?(user)
      ret = super
      if !user.effects[PBEffects::TwoTurnAttack]
        if $fefieldeffect == 40
          @powerHerb = false
          @chargingTurn = true
          @damagingTurn = true
        end
      end
      return ret
    end
    
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} vanished instantly!",user.pbThis))
    end
  
    def pbAttackingTurnEffect(user,target)
      super
      target.effects[PBEffects::BanefulBunker]          = false
      target.effects[PBEffects::KingsShield]            = false
      target.effects[PBEffects::Obstruct]               = false
      target.effects[PBEffects::Protect]                = false
      target.effects[PBEffects::SpikyShield]            = false
      target.pbOwnSide.effects[PBEffects::CraftyShield] = false
      target.pbOwnSide.effects[PBEffects::MatBlock]     = false
      target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
      target.pbOwnSide.effects[PBEffects::WideGuard]    = false
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      if @chargingTurn# && !@damagingTurn # Charging anim
        @battle.pbCommonAnimation("Shadow Force charging",user)
        @chargingTurn = false
      else
        super
      end
    end
  end
  
  
  
  #===============================================================================
  # Two turn attack. Skips first turn, attacks second turn. (Sky Drop)
  # (Handled in Battler's pbSuccessCheckPerHit): Is semi-invulnerable during use.
  # Target is also semi-invulnerable during use, and can't take any action.
  # Doesn't damage airborne Pokémon (but still makes them unable to move during).
  #===============================================================================
  class PokeBattle_Move_0CE < PokeBattle_TwoTurnMove
    def unusableInGravity?; return true; end
  
    def pbIsChargingTurn?(user)
      # NOTE: Sky Drop doesn't benefit from Power Herb, probably because it works
      #       differently (i.e. immobilises the target during use too).
      @powerHerb = false
      @chargingTurn = (user.effects[PBEffects::TwoTurnAttack].nil?)
      @damagingTurn = (!user.effects[PBEffects::TwoTurnAttack].nil?)
      return !@damagingTurn
    end
  
    def pbFailsAgainstTarget?(user,target)
      if !target.opposes?(user)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if target.effects[PBEffects::Substitute]>0 && !ignoresSubstitute?(user)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if Settings::MECHANICS_GENERATION >= 6 && target.pbWeight>=2000   # 200.0kg
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if target.semiInvulnerable? ||
         (target.effects[PBEffects::SkyDrop]>=0 && @chargingTurn)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if target.effects[PBEffects::SkyDrop]!=user.index && @damagingTurn
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbCalcTypeMod(movetypes,user,target)
      return Effectiveness::INEFFECTIVE if target.pbHasType?(:FLYING) || $fefieldeffect == 21
      return super
    end
  
    def pbChargingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} took {2} into the sky!",user.pbThis,targets[0].pbThis(true)))
    end
  
    def pbAttackingTurnMessage(user,targets)
      @battle.pbDisplay(_INTL("{1} was freed from the Sky Drop!",targets[0].pbThis))
    end
  
    def pbChargingTurnEffect(user,target)
      target.effects[PBEffects::SkyDrop] = user.index
    end
  
    def pbAttackingTurnEffect(user,target)
      super
      target.effects[PBEffects::SkyDrop] = -1
    end
    
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      if @chargingTurn && !@damagingTurn # Charging anim
        @battle.pbCommonAnimation("Sky Drop charging",user)
        @battle.pbCommonAnimation("Sky Drop charging",targets[0])
        #@chargingTurn = false
      else
        super
      end
    end
  end
  
  
  
  #===============================================================================
  # Trapping move. Traps for 5 or 6 rounds. Trapped Pokémon lose 1/16 of max HP
  # at end of each round.
  #===============================================================================
  class PokeBattle_Move_0CF < PokeBattle_Move
    def pbEffectAgainstTarget(user,target)
      return if target.fainted? || target.damageState.substitute
      return if target.effects[PBEffects::Trapping]>0
      return if $fefieldeffect == 21 && [:SANDTOMB,:FIRESPIN].include?(@id) && target.grounded?
      # Set trapping effect duration and info
      if $fefieldeffect == 24
        chances = [3,3,4,4,5,6]
        target.effects[PBEffects::Trapping] = chances[@battle.pbRandom(chances.length)]
        target.effects[PBEffects::Trapping] *= 2 if user.hasActiveItem?(:GRIPCLAW)
      else
        if user.hasActiveItem?(:GRIPCLAW)
          target.effects[PBEffects::Trapping] = (Settings::MECHANICS_GENERATION >= 5) ? 8 : 6
        else
          target.effects[PBEffects::Trapping] = 5+@battle.pbRandom(2)
        end
      end
      target.effects[PBEffects::TrappingMove] = @id
      target.effects[PBEffects::TrappingUser] = user.index
      # Message
      msg = _INTL("{1} was trapped in the vortex!",target.pbThis)
      case @id
      when :BIND
        msg = _INTL("{1} was squeezed by {2}!",target.pbThis,user.pbThis(true))
      when :CLAMP
        msg = _INTL("{1} clamped {2}!",user.pbThis,target.pbThis(true))
      when :FIRESPIN
        msg = _INTL("{1} was trapped in the fiery vortex!",target.pbThis)
      when :INFESTATION
        msg = _INTL("{1} has been afflicted with an infestation by {2}!",target.pbThis,user.pbThis(true))
      when :MAGMASTORM
        msg = _INTL("{1} became trapped by Magma Storm!",target.pbThis)
      when :SANDTOMB
        msg = _INTL("{1} became trapped by Sand Tomb!",target.pbThis)
      when :WHIRLPOOL
        msg = _INTL("{1} became trapped in the vortex!",target.pbThis)
      when :SNAPTRAP
        msg = _INTL("{1} was caught in the Snap Trap!",target.pbThis)
      when :THUNDERCAGE
        msg = _INTL("{1} trapped {2} in a Thunder Cage!",user.pbThis,target.pbThis(true))
      when :WRAP
        msg = _INTL("{1} was wrapped by {2}!",target.pbThis,user.pbThis(true))
      end
      @battle.pbDisplay(msg)
      if $fefieldeffect == 21 && target.pbCanConfuse?(user,false,self)
        user.pbConfuse
      end
    end
  end
  
  
  
  #===============================================================================
  # Trapping move. Traps for 5 or 6 rounds. Trapped Pokémon lose 1/16 of max HP
  # at end of each round. (Whirlpool)
  # Power is doubled if target is using Dive. Hits some semi-invulnerable targets.
  #===============================================================================
  class PokeBattle_Move_0D0 < PokeBattle_Move_0CF
    def hitsDivingTargets?; return true; end
  
    def pbModifyDamage(damageMult,user,target)
      damageMult *= 2 if target.inTwoTurnAttack?("0CB")   # Dive
      return damageMult
    end
  end
  
  
  
  #===============================================================================
  # User must use this move for 2 more rounds. No battlers can sleep. (Uproar)
  # NOTE: Bulbapedia claims that an uproar will wake up Pokémon even if they have
  #       Soundproof, and will not allow Pokémon to fall asleep even if they have
  #       Soundproof. I think this is an oversight, so I've let Soundproof Pokémon
  #       be unaffected by Uproar waking/non-sleeping effects.
  #===============================================================================
  class PokeBattle_Move_0D1 < PokeBattle_Move
    def pbEffectGeneral(user)
      return if user.effects[PBEffects::Uproar]>0
      user.effects[PBEffects::Uproar] = 3
      user.currentMove = @id
      @battle.pbDisplay(_INTL("{1} caused an uproar!",user.pbThis))
      @battle.pbPriority(true).each do |b|
        next if b.fainted? || b.status != :SLEEP
        next if b.hasActiveAbility?(:SOUNDPROOF)
        b.pbCureStatus
      end
    end
  end
  
  
  
  #===============================================================================
  # User must use this move for 1 or 2 more rounds. At end, user becomes confused.
  # (Outrage, Petal Dange, Thrash, Raging Fury)
  #===============================================================================
  class PokeBattle_Move_0D2 < PokeBattle_Move
    def pbEffectAfterAllHits(user,target)
      return if @battle.pbCheckGlobalAbility(:SOOTHINGAROMA) && ![8,11,22,26].include?($fefieldeffect)
      if !target.damageState.unaffected && user.effects[PBEffects::Outrage]==0
        if $fefieldeffect == 16
          user.effects[PBEffects::Outrage] = 1
        else
          user.effects[PBEffects::Outrage] = 2+@battle.pbRandom(2)
        end
        user.currentMove = @id
      end
      if user.effects[PBEffects::Outrage]>0
        user.effects[PBEffects::Outrage] -= 1
        if user.effects[PBEffects::Outrage]==0 && user.pbCanConfuseSelf?(false)
          user.pbConfuse(_INTL("{1} became confused due to fatigue!",user.pbThis))
        end
      end
    end
  end
  
  
  
  #===============================================================================
  # User must use this move for 4 more rounds. Power doubles each round.
  # Power is also doubled if user has curled up. (Ice Ball, Rollout)
  #===============================================================================
  class PokeBattle_Move_0D3 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      shift = (5 - user.effects[PBEffects::Rollout])   # 0-4, where 0 is most powerful
      shift = 0 if user.effects[PBEffects::Rollout] == 0   # For first turn
      shift += 1 if user.effects[PBEffects::DefenseCurl]
      baseDmg *= 2**shift
      return baseDmg
    end
  
    def pbEffectAfterAllHits(user,target)
      if !target.damageState.unaffected && user.effects[PBEffects::Rollout] == 0
        user.effects[PBEffects::Rollout] = 5
        user.currentMove = @id
      end
      user.effects[PBEffects::Rollout] -= 1 if user.effects[PBEffects::Rollout] > 0
      if $fefieldeffect == 2
        user.effects[PBEffects::Rollout]=0
        @battle.pbDisplay(_INTL("The grass stopped {1} from rolling!",user.pbThis(true)))
      elsif $fefieldeffect == 7 && @battle.pbRandom(2) == 0 && user.pbCanBurn?(nil,false,self)
        user.pbBurn
      elsif [12,20].include?($fefieldeffect)
        user.effects[PBEffects::Rollout]=0
        @battle.pbDisplay(_INTL("The sand stopped {1} from rolling!",user.pbThis(true)))
      end
    end
  end
  
  
  
  #===============================================================================
  # User bides its time this round and next round. The round after, deals 2x the
  # total direct damage it took while biding to the last battler that damaged it.
  # (Bide)
  #===============================================================================
  class PokeBattle_Move_0D4 < PokeBattle_FixedDamageMove
    def pbAddTarget(targets,user)
      return if user.effects[PBEffects::Bide]!=1   # Not the attack turn
      idxTarget = user.effects[PBEffects::BideTarget]
      t = (idxTarget>=0) ? @battle.battlers[idxTarget] : nil
      if !user.pbAddTarget(targets,user,t,self,false)
        user.pbAddTargetRandomFoe(targets,user,self,false)
      end
    end
  
    def pbMoveFailed?(user,targets)
      return false if user.effects[PBEffects::Bide]!=1   # Not the attack turn
      if user.effects[PBEffects::BideDamage]==0
        @battle.pbDisplay(_INTL("But it failed!"))
        user.effects[PBEffects::Bide] = 0   # No need to reset other Bide variables
        return true
      end
      if targets.length==0
        @battle.pbDisplay(_INTL("But there was no target..."))
        user.effects[PBEffects::Bide] = 0   # No need to reset other Bide variables
        return true
      end
      return false
    end
  
    def pbOnStartUse(user,targets)
      @damagingTurn = (user.effects[PBEffects::Bide]==1)   # If attack turn
    end
  
    def pbDisplayUseMessage(user)
      if @damagingTurn   # Attack turn
        @battle.pbDisplayBrief(_INTL("{1} unleashed energy!",user.pbThis))
      elsif user.effects[PBEffects::Bide]>1   # Charging turns
        @battle.pbDisplayBrief(_INTL("{1} is storing energy!",user.pbThis))
      else
        super   # Start using Bide
      end
    end
  
    def pbDamagingMove?   # Stops damage being dealt in the charging turns
      return false if !@damagingTurn
      return super
    end
  
    def pbFixedDamage(user,target)
      if [5,20,39].include?($fefieldeffect)
        return user.effects[PBEffects::BideDamage]*2.5
      end
      return user.effects[PBEffects::BideDamage]*2
    end
  
    def pbEffectGeneral(user)
      if user.effects[PBEffects::Bide]==0   # Starting using Bide
        if [12,49].include?($fefieldeffect)
          user.effects[PBEffects::Bide] = 2
        else
          user.effects[PBEffects::Bide] = 3
        end
        user.effects[PBEffects::BideDamage] = 0
        user.effects[PBEffects::BideTarget] = -1
        user.currentMove = @id
      end
      user.effects[PBEffects::Bide] -= 1
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      hitNum = 1 if !@damagingTurn   # Charging anim
      super
    end
  end
  
  
  
  #===============================================================================
  # Heals user by 1/2 of its max HP. (Heal Order, Milk Drink, Recover, Slack Off,
  # Soft-Boiled)
  #===============================================================================
  class PokeBattle_Move_0D5 < PokeBattle_HealingMove
    def pbHealAmount(user)
      if @id == :HEALORDER && ([15,47].include?($fefieldeffect) || $fefieldeffect == 33 && 
         $fecounter >= 3)
        return (user.totalhp*2/3.0).round
      elsif @id == :SLACKOFF
        if $fefieldeffect == 48
          return (user.totalhp*2/3.0).round
        elsif $fefieldeffect == 1
          return (user.totalhp/4.0).round
        end
      elsif @id == :MILKDRINK && ([2,12,49].include?($fefieldeffect) || $fefieldeffect == 33 && 
            $fecounter >= 1)
        return (user.totalhp*2/3.0).round
      elsif @id == :SOFTBOILED && $fefieldeffect == 12
        return (user.totalhp*2/3.0).round
      elsif @id == :RECOVER && $fefieldeffect == 19
        return (user.totalhp*2/3.0).round
      end
      return (user.totalhp/2.0).round
    end
    
    def pbEffectGeneral(user)
      super
      if $fefieldeffect == 41 && @id == :MILKDRINK && user.pbCanPoison?(user,false,self)
        user.pbPoison(user)
      end
    end
  end
  
  
  
  #===============================================================================
  # Heals user by 1/2 of its max HP. (Roost)
  # User roosts, and its Flying type is ignored for attacks used against it.
  #===============================================================================
  class PokeBattle_Move_0D6 < PokeBattle_HealingMove
    def pbHealAmount(user)
      if [15,43,47].include?($fefieldeffect)
        return (user.totalhp*2/3.0).round
      else
        return (user.totalhp/2.0).round
      end
    end
  
    def pbEffectAfterAllHits(user,target)
      user.effects[PBEffects::Roost] = true
    end
  end
  
  
  
  #===============================================================================
  # Battler in user's position is healed by 1/2 of its max HP, at the end of the
  # next round. (Wish)
  #===============================================================================
  class PokeBattle_Move_0D7 < PokeBattle_Move
    def healingMove?; return true; end
  
    def pbMoveFailed?(user,targets)
      if @battle.positions[user.index].effects[PBEffects::Wish]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      @battle.positions[user.index].effects[PBEffects::Wish] = 2
      if [9,29,31,34].include?($fefieldeffect)
        @battle.positions[user.index].effects[PBEffects::WishAmount] = (user.totalhp*3/4.0).round
      else
        @battle.positions[user.index].effects[PBEffects::WishAmount] = (user.totalhp/2.0).round
      end
      @battle.positions[user.index].effects[PBEffects::WishMaker] = user.pokemonIndex
    end
  end
  
  
  
  #===============================================================================
  # Heals user by an amount depending on the weather. (Moonlight, Morning Sun,
  # Synthesis)
  #===============================================================================
  class PokeBattle_Move_0D8 < PokeBattle_HealingMove
  =begin
    def pbOnStartUse(user,targets)
      points = 2
      case @battle.pbWeather
      when :Sun, :HarshSun
        if !user.hasUtilityUmbrella
          points += 1
        end
      when :Rain, :HeavyRain
        if !user.hasUtilityUmbrella?
          points -= 1
        end
      when :None, :StrongWinds
      else
        points -= 1
      end
      if [12,48,49].include?($fefieldeffect)
        points += 1
      elsif @id == :SYNTHESIS && ($fefieldeffect == 2 || $fefieldeffect == 33 && $fecounter >= 2)
        points += 1
      elsif @id == :MORNINGSUN && [9,20,34,43].include?($fefieldeffect)
        points += 1
      elsif @id == :MOONLIGHT && [42,43].include?($fefieldeffect)
        points += 1
      elsif [4,34,35].include?($fefieldeffect)
        if @id == :MOONLIGHT
          points += 1
        else
          points -= 1
        end
      elsif [17,18,22,44].include?($fefieldeffect)
        points -= 1
      end
      if points <= 0
        @healAmount = 1
      elsif points == 1
        @healAmount = (user.totalhp/4.0).round
      elsif points == 2
        @healAmount = (user.totalhp/2.0).round
      elsif points == 3
        @healAmount = (user.totalhp*2/3.0).round
      else
        @healAmount = user.totalhp
      end
    end
  =end
  
    def pbHealAmount(user)
      points = 2
      case @battle.pbWeather
      when :Sun, :HarshSun
        if !user.hasUtilityUmbrella
          points += 1
        end
      when :Rain, :HeavyRain
        if !user.hasUtilityUmbrella?
          points -= 1
        end
      when :None, :StrongWinds
      else
        points -= 1
      end
      if [12,48,49].include?($fefieldeffect)
        points += 1
      elsif @id == :SYNTHESIS && ($fefieldeffect == 2 || $fefieldeffect == 33 && $fecounter >= 2)
        points += 1
      elsif @id == :MORNINGSUN && [9,20,34,43].include?($fefieldeffect)
        points += 1
      elsif @id == :MOONLIGHT && [42,43].include?($fefieldeffect)
        points += 1
      elsif [4,34,35].include?($fefieldeffect)
        if @id == :MOONLIGHT
          points += 1
        else
          points -= 1
        end
      elsif [17,18,22,44].include?($fefieldeffect)
        points -= 1
      end
      if points <= 0
        return 1
      elsif points == 1
        return (user.totalhp/4.0).round
      elsif points == 2
        return (user.totalhp/2.0).round
      elsif points == 3
        return (user.totalhp*2/3.0).round
      else
        return user.totalhp
      end
    end
  end
  
  
  
  #===============================================================================
  # Heals user to full HP. User falls asleep for 2 more rounds. (Rest)
  #===============================================================================
  class PokeBattle_Move_0D9 < PokeBattle_HealingMove
    def pbMoveFailed?(user,targets)
      if user.asleep?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return true if !user.pbCanSleep?(user,true,self,true)
      return true if super
      return false
    end
  
    def pbHealAmount(user)
      return user.totalhp-user.hp
    end
  
    def pbEffectGeneral(user)
      if $fefieldeffect == 48
        user.pbSleepSelf(_INTL("{1} slept and became healthy!",user.pbThis),2)
      else
        user.pbSleepSelf(_INTL("{1} slept and became healthy!",user.pbThis),3)
      end
      super
    end
  end
  
  
  
  #===============================================================================
  # Rings the user. Ringed Pokémon gain 1/16 of max HP at the end of each round.
  # (Aqua Ring)
  #===============================================================================
  class PokeBattle_Move_0DA < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if user.effects[PBEffects::AquaRing]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.effects[PBEffects::AquaRing] = true
      @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",user.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # Ingrains the user. Ingrained Pokémon gain 1/16 of max HP at the end of each
  # round, and cannot flee or switch out. (Ingrain)
  #===============================================================================
  class PokeBattle_Move_0DB < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if user.effects[PBEffects::Ingrain]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.effects[PBEffects::Ingrain] = true
      @battle.pbDisplay(_INTL("{1} planted its roots!",user.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # Seeds the target. Seeded Pokémon lose 1/8 of max HP at the end of each round,
  # and the Pokémon in the user's position gains the same amount. (Leech Seed)
  #===============================================================================
  class PokeBattle_Move_0DC < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      if target.effects[PBEffects::LeechSeed]>=0
        @battle.pbDisplay(_INTL("{1} evaded the attack!",target.pbThis))
        return true
      end
      if target.pbHasType?(:GRASS)
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
        return true
      end
      return false
    end
  
    def pbMissMessage(user,target)
      @battle.pbDisplay(_INTL("{1} evaded the attack!",target.pbThis))
      return true
    end
  
    def pbEffectAgainstTarget(user,target)
      target.effects[PBEffects::LeechSeed] = user.index
      @battle.pbDisplay(_INTL("{1} was seeded!",target.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # User gains half the HP it inflicts as damage.
  #===============================================================================
  class PokeBattle_Move_0DD < PokeBattle_Move
    def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end
  
    def pbEffectAgainstTarget(user,target)
      return if target.damageState.hpLost<=0
      hpGain = (target.damageState.hpLost/2.0).round
      user.pbRecoverHPFromDrain(hpGain,target)
    end
  end
  
  
  
  #===============================================================================
  # User gains half the HP it inflicts as damage. Fails if target is not asleep.
  # (Dream Eater)
  #===============================================================================
  class PokeBattle_Move_0DE < PokeBattle_Move
    def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end
  
    def pbFailsAgainstTarget?(user,target)
      if !target.asleep? && ![3,9,31,34,40,42].include?($fefieldeffect)
        @battle.pbDisplay(_INTL("{1} wasn't affected!",target.pbThis))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      return if target.damageState.hpLost<=0
      hpGain = (target.damageState.hpLost/2.0).round
      user.pbRecoverHPFromDrain(hpGain,target)
    end
  end
  
  
  
  #===============================================================================
  # Heals target by 1/2 of its max HP. (Heal Pulse)
  #===============================================================================
  class PokeBattle_Move_0DF < PokeBattle_Move
    def healingMove?; return true; end
  
    def pbFailsAgainstTarget?(user,target)
      if target.hp==target.totalhp
        @battle.pbDisplay(_INTL("{1}'s HP is full!",target.pbThis))
        return true
      elsif !target.canHeal?
        @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
        return true
      end
      return false
    end
  
    def pbHealAmount(user,target)
      points = 2
      if pulseMove? && user.hasActiveAbility?(:MEGALAUNCHER)
        points += 1
      end
      if [3,9,29].include?($fefieldeffect)
        points += 1
      end
      if points <= 0
        return 1
      elsif points == 1
        return (target.totalhp/4.0).round
      elsif points == 2
        return (target.totalhp/2.0).round
      elsif points == 3
        return (target.totalhp*3/4.0).round
      else
        return target.totalhp
      end
    end
    
    def pbEffectAgainstTarget(user,target)
      target.pbRecoverHP(pbHealAmount(user,target))
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # User faints, even if the move does nothing else. (Explosion, Self-Destruct)
  #===============================================================================
  class PokeBattle_Move_0E0 < PokeBattle_Move
    def worksWithNoTargets?;     return true; end
    def pbNumHits(user,targets); return 1;    end
  
    def pbMoveFailed?(user,targets)
      if !@battle.moldBreaker
        if @battle.dampBattler?
          @battle.pbDisplay(_INTL("The dampness prevents {1}'s use of {2}!",user.pbThis(true),@name))
          return true
        end
      end
      return false
    end
  
    def pbSelfKO(user)
      return if user.fainted?
      user.pbReduceHP(user.hp,false,true,true,true)
      user.pbItemHPHealCheck
    end
  end
  
  
  
  #===============================================================================
  # Inflicts fixed damage equal to user's current HP. (Final Gambit)
  # User faints (if successful).
  #===============================================================================
  class PokeBattle_Move_0E1 < PokeBattle_FixedDamageMove
    def pbNumHits(user,targets); return 1; end
  
    def pbOnStartUse(user,targets)
      if [6,31].include?($fefieldeffect)
        @finalGambitDamage = user.hp * 1.5
      elsif [29,45].include?($fefieldeffect)
        @finalGambitDamage = user.hp * 2
      else
        @finalGambitDamage = user.hp
      end
    end
  
    def pbFixedDamage(user,target)
      return @finalGambitDamage
    end
  
    def pbSelfKO(user)
      return if user.fainted?
      user.pbReduceHP(user.hp,false,true,true,true)
      user.pbItemHPHealCheck
    end
  end
  
  
  
  #===============================================================================
  # Decreases the target's Attack and Special Attack by 2 stages each. (Memento)
  # User faints (if successful).
  #===============================================================================
  class PokeBattle_Move_0E2 < PokeBattle_TargetStatDownMove
    def getStatDown
      statDown = [:ATTACK,2,:SPECIAL_ATTACK,2]
      return statDown
    end
  
    # NOTE: The user faints even if the target's stats cannot be changed, so this
    #       method must always return false to allow the move's usage to continue.
    def pbFailsAgainstTarget?(user,target)
      return false
    end
  
    def pbSelfKO(user)
      return if user.fainted? || $fefieldeffect == 40
      user.pbReduceHP(user.hp,false,true,true,true)
      user.pbItemHPHealCheck
    end
  end
  
  
  
  #===============================================================================
  # User faints. The Pokémon that replaces the user is fully healed (HP and
  # status). Fails if user won't be replaced. (Healing Wish)
  #===============================================================================
  class PokeBattle_Move_0E3 < PokeBattle_Move
    def healingMove?; return true; end
  
    def pbMoveFailed?(user,targets)
      if !@battle.pbCanChooseNonActive?(user.index)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbSelfKO(user)
      return if user.fainted?
      user.pbReduceHP(user.hp,false,true,true,true)
      user.pbItemHPHealCheck
      @battle.positions[user.index].effects[PBEffects::HealingWish] = true
    end
  end
  
  
  
  #===============================================================================
  # User faints. The Pokémon that replaces the user is fully healed (HP, PP and
  # status). Fails if user won't be replaced. (Lunar Dance)
  #===============================================================================
  class PokeBattle_Move_0E4 < PokeBattle_Move
    def healingMove?; return true; end
  
    def pbMoveFailed?(user,targets)
      if !@battle.pbCanChooseNonActive?(user.index)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbSelfKO(user)
      return if user.fainted?
      user.pbReduceHP(user.hp,false,true,true,true)
      user.pbItemHPHealCheck
      @battle.positions[user.index].effects[PBEffects::LunarDance] = true
    end
  end
  
  
  
  #===============================================================================
  # All current battlers will perish after 3 more rounds. (Perish Song)
  #===============================================================================
  class PokeBattle_Move_0E5 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      failed = true
      targets.each do |b|
        next if b.effects[PBEffects::PerishSong]>0   # Heard it before
        failed = false
        break
      end
      if failed
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbFailsAgainstTarget?(user,target)
      return target.effects[PBEffects::PerishSong]>0   # Heard it before
    end
  
    def pbEffectAgainstTarget(user,target)
      target.effects[PBEffects::PerishSong]     = 4 if !($fefieldeffect == 39 && !user.opposes?(target)) &&
                                                       !($fefieldeffect == 40 && target.pbHasType?(:GHOST))
      target.effects[PBEffects::PerishSongUser] = user.index
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      super
      @battle.pbDisplay(_INTL("All Pokémon that hear the song will faint in three turns!"))
    end
  end
  
  
  
  #===============================================================================
  # If user is KO'd before it next moves, the attack that caused it loses all PP.
  # (Grudge)
  #===============================================================================
  class PokeBattle_Move_0E6 < PokeBattle_Move
    def pbEffectGeneral(user)
      user.effects[PBEffects::Grudge] = true
      @battle.pbDisplay(_INTL("{1} wants its target to bear a grudge!",user.pbThis))
      if $fefieldeffect == 40
        user.effects[PBEffects::DestinyBond] = true
        @battle.pbDisplay(_INTL("{1} is hoping to take its attacker down with it!",user.pbThis))
      end
    end
  end
  
  
  
  #===============================================================================
  # If user is KO'd before it next moves, the battler that caused it also faints.
  # (Destiny Bond)
  #===============================================================================
  class PokeBattle_Move_0E7 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if Settings::MECHANICS_GENERATION >= 7 && user.effects[PBEffects::DestinyBondPrevious] &&
         ![31,40].include?($fefieldeffect)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      user.effects[PBEffects::DestinyBond] = true
      @battle.pbDisplay(_INTL("{1} is hoping to take its attacker down with it!",user.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # If user would be KO'd this round, it survives with 1HP instead. (Endure)
  #===============================================================================
  class PokeBattle_Move_0E8 < PokeBattle_ProtectMove
    def initialize(battle,move)
      super
      @effect = PBEffects::Endure
    end
  
    def pbProtectMessage(user)
      @battle.pbDisplay(_INTL("{1} braced itself!",user.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # If target would be KO'd by this attack, it survives with 1HP instead.
  # (False Swipe, Hold Back)
  #===============================================================================
  class PokeBattle_Move_0E9 < PokeBattle_Move
    def nonLethal?(user,target); return true; end
  end
  
  
  
  #===============================================================================
  # User flees from battle. Fails in trainer battles. (Teleport)
  #===============================================================================
  class PokeBattle_Move_0EA < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if !@battle.pbCanChooseNonActive?(user.index) || user.fainted?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
      return if user.fainted? || numHits==0
      return if !@battle.pbCanChooseNonActive?(user.index)
      
      @battle.pbDisplay(_INTL("{1} went back to {2}!",user.pbThis,
         @battle.pbGetOwnerName(user.index)))
      @battle.pbPursuit(user.index)
      return if user.fainted?
      newPkmn = @battle.pbGetReplacementPokemonIndex(user.index)   # Owner chooses
      return if newPkmn<0
      @battle.pbRecallAndReplace(user.index,newPkmn)
      @battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
      @battle.moldBreaker = false
      switchedBattlers.push(user.index)
      user.pbEffectsOnSwitchIn(true)
    end
    
    def pbEffectGeneral(user)
      return if $fefieldeffect != 37
      numTargets = 0
      allies = []
      idxUserOwner = @battle.pbGetOwnerIndexFromBattlerIndex(user.index)
      user.eachAlly do |b|
        next if @battle.pbGetOwnerIndexFromBattlerIndex(b.index)!=idxUserOwner
        allies.push(b.index)
      end
      return if allies.length == 0
      idxA = user.index
      idxB = allies[rand(allies.length)]
      user.effects[PBEffects::SwitchedAlly] = idxB
      if @battle.pbSwapBattlers(idxA,idxB)
        @battle.pbDisplay(_INTL("{1} and {2} switched places!",
        @battle.battlers[idxB].pbThis,@battle.battlers[idxA].pbThis(true)))
        if Settings::MECHANICS_GENERATION >= 8
              @battle.pbActivateHealingWish(@battle.battlers[idxA])
              @battle.pbActivateHealingWish(@battle.battlers[idxB])
        end
      end
    end
  end
  
  
  
  #===============================================================================
  # In wild battles, makes target flee. Fails if target is a higher level than the
  # user.
  # In trainer battles, target switches out.
  # For status moves. (Roar, Whirlwind)
  #===============================================================================
  class PokeBattle_Move_0EB < PokeBattle_Move
    def ignoresSubstitute?(user); return true; end
  
    def pbFailsAgainstTarget?(user,target)
      if @id == :ROAR && $fefieldeffect == 8
        @battle.pbDisplay(_INTL("What are ya doin' in my swamp?!"))
      end
      if target.hasSuctionCups? && !@battle.moldBreaker
        @battle.pbShowAbilitySplash(target)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} anchors itself!",target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1} anchors itself with {2}!",target.pbThis,target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
        return true
      end
      if target.effects[PBEffects::Ingrain]
        @battle.pbDisplay(_INTL("{1} anchored itself with its roots!",target.pbThis))
        return true
      end
      if !@battle.canRun
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if @battle.wildBattle? && target.level>user.level
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if @battle.trainerBattle?
        canSwitch = false
        @battle.eachInTeamFromBattlerIndex(target.index) do |_pkmn,i|
          next if !@battle.pbCanSwitchLax?(target.index,i)
          canSwitch = true
          break
        end
        if !canSwitch
          @battle.pbDisplay(_INTL("But it failed!"))
          return true
        end
      end
      if $fefieldeffect == 44
        @battle.pbDisplay(_INTL("But there was nowhere to go!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      @battle.decision = 3 if @battle.wildBattle?   # Escaped from battle
    end
  
    def pbSwitchOutTargetsEffect(user,targets,numHits,switchedBattlers)
      return if @battle.wildBattle?
      return if user.fainted? || numHits==0
      roarSwitched = []
      targets.each do |b|
        next if b.fainted? || b.damageState.unaffected || switchedBattlers.include?(b.index)
        newPkmn = @battle.pbGetReplacementPokemonIndex(b.index,true)   # Random
        next if newPkmn<0
        @battle.pbRecallAndReplace(b.index, newPkmn, true)
        @battle.pbDisplay(_INTL("{1} was dragged out!",b.pbThis))
        @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
        switchedBattlers.push(b.index)
        roarSwitched.push(b.index)
      end
      if roarSwitched.length>0
        @battle.moldBreaker = false if roarSwitched.include?(user.index)
        @battle.pbPriority(true).each do |b|
          b.pbEffectsOnSwitchIn(true) if roarSwitched.include?(b.index)
        end
      end
    end
    
    def pbEffectGeneral(user)
      if $fefieldeffect == 32
        user.pbRaiseStatStage(:ATTACK,1,user)
      end
    end
  end
  
  
  
  #===============================================================================
  # In wild battles, makes target flee. Fails if target is a higher level than the
  # user.
  # In trainer battles, target switches out.
  # For damaging moves. (Circle Throw, Dragon Tail)
  #===============================================================================
  class PokeBattle_Move_0EC < PokeBattle_Move
    def pbEffectAgainstTarget(user,target)
      if @battle.wildBattle? && target.level<=user.level && @battle.canRun &&
         (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user)) &&
         $fefieldeffect != 44
        @battle.decision = 3
      end
    end
  
    def pbSwitchOutTargetsEffect(user,targets,numHits,switchedBattlers)
      return if @battle.wildBattle?
      return if user.fainted? || numHits==0
      return if $fefieldeffect == 44
      roarSwitched = []
      targets.each do |b|
        next if b.fainted? || b.damageState.unaffected || b.damageState.substitute
        next if switchedBattlers.include?(b.index)
        next if b.effects[PBEffects::Ingrain]
        next if b.hasSuctionCups? && !@battle.moldBreaker
        newPkmn = @battle.pbGetReplacementPokemonIndex(b.index,true)   # Random
        next if newPkmn<0
        @battle.pbRecallAndReplace(b.index, newPkmn, true)
        @battle.pbDisplay(_INTL("{1} was dragged out!",b.pbThis))
        @battle.pbClearChoice(b.index)   # Replacement Pokémon does nothing this round
        switchedBattlers.push(b.index)
        roarSwitched.push(b.index)
      end
      if roarSwitched.length>0
        @battle.moldBreaker = false if roarSwitched.include?(user.index)
        @battle.pbPriority(true).each do |b|
          b.pbEffectsOnSwitchIn(true) if roarSwitched.include?(b.index)
        end
      else
        @battle.pbCommonAnimation("Fade in",target)
      end
    end
  end
  
  
  
  #===============================================================================
  # User switches out. Various effects affecting the user are passed to the
  # replacement. (Baton Pass)
  #===============================================================================
  class PokeBattle_Move_0ED < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if !@battle.pbCanChooseNonActive?(user.index)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
      return if user.fainted? || numHits==0
      return if !@battle.pbCanChooseNonActive?(user.index)
      @battle.pbPursuit(user.index)
      return if user.fainted?
      newPkmn = @battle.pbGetReplacementPokemonIndex(user.index)   # Owner chooses
      return if newPkmn<0
      @battle.pbRecallAndReplace(user.index, newPkmn, false, true)
      @battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
      @battle.moldBreaker = false
      switchedBattlers.push(user.index)
      user.pbEffectsOnSwitchIn(true)
    end
  end
  
  
  
  #===============================================================================
  # After inflicting damage, user switches out. Ignores trapping moves.
  # (U-turn, Volt Switch)
  #===============================================================================
  class PokeBattle_Move_0EE < PokeBattle_Move
    def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
      return if user.fainted? || numHits==0
      targetSwitched = true
      targets.each do |b|
        targetSwitched = false if !switchedBattlers.include?(b.index)
      end
      if targetSwitched || !@battle.pbCanChooseNonActive?(user.index)
        @battle.pbCommonAnimation("Fade in",user)
        return
      end
      @battle.pbDisplay(_INTL("{1} went back to {2}!",user.pbThis,
         @battle.pbGetOwnerName(user.index)))
      @battle.pbPursuit(user.index)
      return if user.fainted?
      newPkmn = @battle.pbGetReplacementPokemonIndex(user.index)   # Owner chooses
      return if newPkmn<0
      @battle.pbRecallAndReplace(user.index,newPkmn)
      @battle.pbClearChoice(user.index)   # Replacement Pokémon does nothing this round
      @battle.moldBreaker = false
      switchedBattlers.push(user.index)
      user.pbEffectsOnSwitchIn(true)
    end
  end
  
  
  
  #===============================================================================
  # Target can no longer switch out or flee, as long as the user remains active.
  # (Anchor Shot, Block, Mean Look, Spider Web, Spirit Shackle, Thousand Waves)
  #===============================================================================
  class PokeBattle_Move_0EF < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      return false if damagingMove?
      if target.effects[PBEffects::MeanLook]>=0
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
      return if damagingMove?
      target.effects[PBEffects::MeanLook] = user.index
      @battle.pbDisplay(_INTL("{1} can no longer escape!",target.pbThis))
      if @id == :SPIDERWEB && [15,47].include?($fefieldeffect) && !user.pbOpposingSide.effects[PBEffects::StickyWeb]
        user.pbOpposingSide.effects[PBEffects::StickyWeb] = true
        user.pbOpposingSide.effects[PBEffects::StickyWebUser] = user.index
        @battle.pbDisplay(_INTL("A sticky web has been laid out beneath {1}'s feet!",user.pbOpposingTeam(true)))
      elsif @id == :BLOCK && $fefieldeffect == 5
        user.pbRaiseStatStage(:DEFENSE,2,user)
      end
    end
  
    def pbAdditionalEffect(user,target)
      return if target.fainted? || target.damageState.substitute
      return if target.effects[PBEffects::MeanLook]>=0
      return if Settings::MORE_TYPE_EFFECTS && target.pbHasType?(:GHOST)
      target.effects[PBEffects::MeanLook] = user.index
      @battle.pbDisplay(_INTL("{1} can no longer escape!",target.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # Target drops its item. It regains the item at the end of the battle. (Knock Off)
  # If target has a losable item, damage is multiplied by 1.5.
  #===============================================================================
  class PokeBattle_Move_0F0 < PokeBattle_Move
    def pbBaseDamage(baseDmg,user,target)
      if Settings::MECHANICS_GENERATION >= 6 &&
         target.item && !target.unlosableItem?(target.item)
         # NOTE: Damage is still boosted even if target has Sticky Hold or a
         #       substitute.
        baseDmg = (baseDmg*1.5).round
      end
      return baseDmg
    end
  
    def pbEffectAfterAllHits(user,target)
      return if @battle.wildBattle? && user.opposes?   # Wild Pokémon can't knock off
      return if user.fainted?
      return if target.damageState.unaffected || target.damageState.substitute
      return if !target.item || target.unlosableItem?(target.item)
      return if target.hasStickyHold? && !@battle.moldBreaker
      itemName = target.itemName
      target.pbRemoveItem(false)
      @battle.pbDisplay(_INTL("{1} dropped its {2}!",target.pbThis,itemName))
    end
  end
  
  
  
  #===============================================================================
  # User steals the target's item, if the user has none itself. (Covet, Thief)
  # Items stolen from wild Pokémon are kept after the battle.
  #===============================================================================
  class PokeBattle_Move_0F1 < PokeBattle_Move
    def pbEffectAfterAllHits(user,target)
      return if @battle.wildBattle? && user.opposes?   # Wild Pokémon can't thieve
      return if user.fainted?
      return if target.damageState.unaffected || target.damageState.substitute
      return if !target.item || user.item
      return if target.unlosableItem?(target.item)
      return if user.unlosableItem?(target.item)
      return if target.hasStickyHold? && !@battle.moldBreaker
      itemName = target.itemName
      user.item = target.item
      # Permanently steal the item from wild Pokémon
      if @battle.wildBattle? && target.opposes? &&
         target.initialItem==target.item && !user.initialItem
        user.setInitialItem(target.item)
        target.pbRemoveItem
      else
        target.pbRemoveItem(false)
      end
      @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,target.pbThis(true),itemName))
      user.pbHeldItemTriggerCheck
    end
  end
  
  
  
  #===============================================================================
  # User and target swap items. They remain swapped after wild battles.
  # (Switcheroo, Trick)
  #===============================================================================
  class PokeBattle_Move_0F2 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if @battle.wildBattle? && user.opposes?
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbFailsAgainstTarget?(user,target)
      if !user.item && !target.item
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if target.unlosableItem?(target.item) ||
         target.unlosableItem?(user.item) ||
         user.unlosableItem?(user.item) ||
         user.unlosableItem?(target.item)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      if target.hasStickyHold? && !@battle.moldBreaker
        @battle.pbShowAbilitySplash(target)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("But it failed to affect {1}!",target.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("But it failed to affect {1} because of its {2}!",
             target.pbThis(true),target.abilityName))
        end
        @battle.pbHideAbilitySplash(target)
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      oldUserItem = user.item;     oldUserItemName = user.itemName
      oldTargetItem = target.item; oldTargetItemName = target.itemName
      user.item                             = oldTargetItem
      user.effects[PBEffects::ChoiceBand]   = nil
      user.activateUnburden if (!user.item && oldUserItem)
      target.item                           = oldUserItem
      target.effects[PBEffects::ChoiceBand] = nil
      target.activateUnburden if (!target.item && oldTargetItem)
      # Permanently steal the item from wild Pokémon
      if @battle.wildBattle? && target.opposes? &&
         target.initialItem==oldTargetItem && !user.initialItem
        user.setInitialItem(oldTargetItem)
      end
      @battle.pbDisplay(_INTL("{1} switched items with {2}!",user.pbThis,target.pbThis(true)))
      if $fefieldeffect != 18 && !($fefieldeffect == 6 && @id == :TRICK)
        @battle.pbDisplay(_INTL("{1} obtained {2}.",user.pbThis,oldTargetItemName)) if oldTargetItem
        @battle.pbDisplay(_INTL("{1} obtained {2}.",target.pbThis,oldUserItemName)) if oldUserItem
      end
      user.pbHeldItemTriggerCheck
      target.pbHeldItemTriggerCheck
      if [40,42].include?($fefieldeffect) && @id == :TRICK
        target.pbLowerStatStage(:ACCURACY,1,user)
      end
    end
  end
  
  
  
  #===============================================================================
  # User gives its item to the target. The item remains given after wild battles.
  # (Bestow)
  #===============================================================================
  class PokeBattle_Move_0F3 < PokeBattle_Move
    def ignoresSubstitute?(user)
      return true if Settings::MECHANICS_GENERATION >= 6
      return super
    end
  
    def pbMoveFailed?(user,targets)
      if !user.item || user.unlosableItem?(user.item)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbFailsAgainstTarget?(user,target)
      if target.item || target.unlosableItem?(user.item)
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      itemName = user.itemName
      target.item = user.item
      # Permanently steal the item from wild Pokémon
      if @battle.wildBattle? && user.opposes? &&
         user.initialItem==user.item && !target.initialItem
        target.setInitialItem(user.item)
        user.pbRemoveItem
      else
        user.pbRemoveItem(false)
      end
      @battle.pbDisplay(_INTL("{1} received {2} from {3}!",target.pbThis,itemName,user.pbThis(true)))
      target.pbHeldItemTriggerCheck
    end
  end
  
  
  
  #===============================================================================
  # User consumes target's berry and gains its effect. (Bug Bite, Pluck)
  #===============================================================================
  class PokeBattle_Move_0F4 < PokeBattle_Move
    def pbEffectAfterAllHits(user,target)
      return if user.fainted? || target.fainted?
      return if target.damageState.unaffected || target.damageState.substitute
      return if !target.item || !target.item.is_berry?
      return if target.hasStickyHold? && !@battle.moldBreaker
      item = target.item
      itemName = target.itemName
      target.pbRemoveItem
      @battle.pbDisplay(_INTL("{1} stole and ate its target's {2}!",user.pbThis,itemName))
      user.pbHeldItemTriggerCheck(item,false)
    end
    
    def pbCalcTypeModSingle(moveTypes,defType,user,target)
      return 2*super if defType == :FLYING && @id == :PLUCK
      return super
    end
  end
  
  
  
  #===============================================================================
  # Target's berry/Gem is destroyed. (Incinerate)
  #===============================================================================
  class PokeBattle_Move_0F5 < PokeBattle_Move
    def pbEffectWhenDealingDamage(user,target)
      return if target.damageState.substitute || target.damageState.berryWeakened
      return if !target.item || (!target.item.is_berry? && !(Settings::MECHANICS_GENERATION >= 6 && 
                target.item.is_gem?))
      return if $fefieldeffect == 21 && target.grounded?
      target.pbRemoveItem
      @battle.pbDisplay(_INTL("{1}'s {2} was incinerated!",target.pbThis,target.itemName))
    end
  end
  
  
  
  #===============================================================================
  # User recovers the last item it held and consumed. (Recycle)
  #===============================================================================
  class PokeBattle_Move_0F6 < PokeBattle_Move
    def pbMoveFailed?(user,targets)
      if !user.recycleItem
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectGeneral(user)
      item = user.recycleItem
      user.item = item
      user.setInitialItem(item) if @battle.wildBattle? && !user.initialItem
      user.setRecycleItem(nil)
      user.effects[PBEffects::PickupItem] = nil
      user.effects[PBEffects::PickupUse]  = 0
      itemName = GameData::Item.get(item).name
      if itemName.starts_with_vowel?
        @battle.pbDisplay(_INTL("{1} found an {2}!",user.pbThis,itemName))
      else
        @battle.pbDisplay(_INTL("{1} found a {2}!",user.pbThis,itemName))
      end
      user.pbHeldItemTriggerCheck
      if $fefieldeffect == 19 && user.canHeal?
        if user.pbRecoverHP(user.totalhp/4) > 0
          @battle.pbDisplay(_INTL("{1} restored some of its HP!",user.pbThis))
        end
      end
    end
  end
  
  
  
  #===============================================================================
  # User flings its item at the target. Power/effect depend on the item. (Fling)
  #===============================================================================
  class PokeBattle_Move_0F7 < PokeBattle_Move
    def initialize(battle,move)
      super
      # 80 => all Mega Stones
      # 10 => all Berries
      @flingPowers = {
        130 => [:IRONBALL
               ],
        100 => [:HARDSTONE,:RAREBONE,
                # Fossils
                :ARMORFOSSIL,:CLAWFOSSIL,:COVERFOSSIL,:DOMEFOSSIL,:HELIXFOSSIL,
                :JAWFOSSIL,:OLDAMBER,:PLUMEFOSSIL,:ROOTFOSSIL,:SAILFOSSIL,
                :SKULLFOSSIL,:FOSSILIZEDBIRD,:FOSSILIZEDFISH,:FOSSILIZEDDRAKE,
                :FOSSILIZEDDINO
               ],
         90 => [:DEEPSEATOOTH,:GRIPCLAW,:THICKCLUB,
                # Plates
                :DRACOPLATE,:DREADPLATE,:EARTHPLATE,:FISTPLATE,:FLAMEPLATE,
                :ICICLEPLATE,:INSECTPLATE,:IRONPLATE,:MEADOWPLATE,:MINDPLATE,
                :PIXIEPLATE,:SKYPLATE,:SPLASHPLATE,:SPOOKYPLATE,:STONEPLATE,
                :TOXICPLATE,:ZAPPLATE,:BLANKPLATE
               ],
         80 => [:ASSAULTVEST,:DAWNSTONE,:DUSKSTONE,:ELECTIRIZER,:MAGMARIZER,
                :ODDKEYSTONE,:OVALSTONE,:PROTECTOR,:QUICKCLAW,:RAZORCLAW,:SACHET,
                :SAFETYGOGGLES,:SHINYSTONE,:STICKYBARB,:WEAKNESSPOLICY,
                :WHIPPEDDREAM,:BLACKAUGURITE
               ],
         70 => [:DRAGONFANG,:POISONBARB,
                # EV-training items (Macho Brace is 60)
                :POWERANKLET,:POWERBAND,:POWERBELT,:POWERBRACER,:POWERLENS,
                :POWERWEIGHT,
                # Drives
                :BURNDRIVE,:CHILLDRIVE,:DOUSEDRIVE,:SHOCKDRIVE
               ],
         60 => [:ADAMANTORB,:DAMPROCK,:GRISEOUSORB,:HEATROCK,:LUSTROUSORB,
                :MACHOBRACE,:ROCKYHELMET,:STICK,:TERRAINEXTENDER
               ],
         50 => [:DUBIOUSDISC,:SHARPBEAK,
                # Memories
                :BUGMEMORY,:DARKMEMORY,:DRAGONMEMORY,:ELECTRICMEMORY,:FAIRYMEMORY,
                :FIGHTINGMEMORY,:FIREMEMORY,:FLYINGMEMORY,:GHOSTMEMORY,
                :GRASSMEMORY,:GROUNDMEMORY,:ICEMEMORY,:POISONMEMORY,
                :PSYCHICMEMORY,:ROCKMEMORY,:STEELMEMORY,:WATERMEMORY
               ],
         40 => [:EVIOLITE,:ICYROCK,:LUCKYPUNCH
               ],
         30 => [:ABSORBBULB,:ADRENALINEORB,:AMULETCOIN,:BINDINGBAND,:BLACKBELT,
                :BLACKGLASSES,:BLACKSLUDGE,:BOTTLECAP,:CELLBATTERY,:CHARCOAL,
                :CLEANSETAG,:DEEPSEASCALE,:DRAGONSCALE,:EJECTBUTTON,:ESCAPEROPE,
                :EXPSHARE,:FLAMEORB,:FLOATSTONE,:FLUFFYTAIL,:GOLDBOTTLECAP,
                :HEARTSCALE,:HONEY,:KINGSROCK,:LIFEORB,:LIGHTBALL,:LIGHTCLAY,
                :LUCKYEGG,:LUMINOUSMOSS,:MAGNET,:METALCOAT,:METRONOME,
                :MIRACLESEED,:MYSTICWATER,:NEVERMELTICE,:PASSORB,:POKEDOLL,
                :POKETOY,:PRISMSCALE,:PROTECTIVEPADS,:RAZORFANG,:SACREDASH,
                :SCOPELENS,:SHELLBELL,:SHOALSALT,:SHOALSHELL,:SMOKEBALL,:SNOWBALL,
                :SOULDEW,:SPELLTAG,:TOXICORB,:TWISTEDSPOON,:UPGRADE,
                # Healing items
                :ANTIDOTE,:ANTIDOTE1,:AWAKENING,:AWAKENING1,:BERRYJUICE,
                :BERRYJUICE1,:BIGMALASADA,:BIGMALASADA1,:BLUEFLUTE,:BURNHEAL,
                :BURNHEAL1,:CASTELIACONE,:CASTELIACONE1,:ELIXIR,:ELIXIR1,
                :ENERGYPOWDER,:ENERGYPOWDER1,:ENERGYROOT,:ENERGYROOT1,:ETHER,
                :ETHER1,:FRESHWATER,:FRESHWATER1,:FULLHEAL,:FULLHEAL1,
                :FULLRESTORE,:FULLRESTORE1,:HEALPOWDER,:HEALPOWDER1,:HYPERPOTION,
                :HYPERPOTION1,:ICEHEAL,:ICEHEAL1,:LAVACOOKIE,:LAVACOOKIE1,
                :LEMONADE,:LEMONADE1,:LUMIOSEGALETTE,:LUMIOSEGALETTE1,:MAXELIXIR,
                :MAXELIXIR1,:MAXETHER,:MAXETHER1,:MAXPOTION,:MAXPOTION1,
                :MAXREVIVE,:MAXREVIVE1,:MOOMOOMILK,:MOOMOOMILK1,:OLDGATEAU,
                :OLDGATEAU1,:PARALYZEHEAL,:PARLYZEHEAL1,:PEWTERCRUNCHIES,
                :PEWTERCRUNCHIES1,:POTION,:POTION1,:RAGECANDYBAR,:RAGECANDYBAR1,
                :REDFLUTE,:REVIVALHERB,:REVIVE,:SHALOURSABLE,:SODAPOP,
                :SUPERPOTION,:SUPERPOTION1,:SWEETHEART,:SWEETHEART1,:YELLOWFLUTE,
                :COFFEE,:COFFEE1,:KONIKONIFRIEDCOMBUSKEN,:KONIKONIFRIEDCOMBUSKEN1,
                :FRESHCREAM,:FRESHCREAM1,:BRITTLEBONES,:BRITTLEBONES1,:BOILEDEGG,
                :BOILEDEGG1,:BREAD,:BREAD1,:INSTANTNOODLES,:INSTANTNOODLES1,
                :FRIEDFOOD,:FRIEDFOOD1,:KRABBYCAKE,:KRABBYCAKE1,:COCONUTMILK,
                :COCONUTMILK1,:MOOMOOCHEESE,:MOOMOOCHEESE1,:PRECOOKEDBURGER,
                :PRECOOKEDBURGER1,:PACKAGEDCURRY,:PACKAGEDCURRY1,:PASTA,:PASTA1,
                :SMOKEPOKETAIL,:SMOKEPOKETAIL1,:PEKINGPSYDUCK,:PEKINGPSYDUCK1,
                :SHARPEDOFINSOUP,:SHARPEDOFINSOUP1,:GIGANTAMIX,:GIGANTAMIX1,
                # Battle items
                :XACCURACY,:XACCURACY2,:XACCURACY3,:XACCURACY6,
                :XATTACK,:XATTACK2,:XATTACK3,:XATTACK6,
                :XDEFEND,:XDEFEND2,:XDEFEND3,:XDEFEND6,
                :XDEFENSE,:XDEFENSE2,:XDEFENSE3,:XDEFENSE6,
                :XSPATK,:XSPATK2,:XSPATK3,:XSPATK6,
                :XSPECIAL,:XSPECIAL2,:XSPECIAL3,:XSPECIAL6,
                :XSPDEF,:XSPDEF2,:XSPDEF3,:XSPDEF6,
                :XSPEED,:XSPEED2,:XSPEED3,:XSPEED6,
                :DIREHIT,:DIREHIT2,:DIREHIT3,
                :ABILITYURGE,:GUARDSPEC,:ITEMDROP,:ITEMURGE,:RESETURGE,
                # Vitamins
                :CALCIUM,:CARBOS,:HPUP,:IRON,:PPUP,:PPMAX,:PROTEIN,:ZINC,
                :RARECANDY,
                # Most evolution stones (see also 80)
                :EVERSTONE,:FIRESTONE,:ICESTONE,:LEAFSTONE,:MOONSTONE,:SUNSTONE,
                :THUNDERSTONE,:WATERSTONE,:PEATBLOCK,:LINKINGCORD,
                # Repels
                :MAXREPEL,:REPEL,:SUPERREPEL,:LURE,:SUPERLURE,:MAXLURE,
                # Mulches
                :AMAZEMULCH,:BOOSTMULCH,:DAMPMULCH,:GOOEYMULCH,:GROWTHMULCH,
                :RICHMULCH,:STABLEMULCH,:SURPRISEMULCH,
                # Shards
                :BLUESHARD,:GREENSHARD,:REDSHARD,:YELLOWSHARD,
                # Valuables
                :BALMMUSHROOM,:BIGMUSHROOM,:BIGNUGGET,:BIGPEARL,:COMETSHARD,
                :NUGGET,:PEARL,:PEARLSTRING,:RELICBAND,:RELICCOPPER,:RELICCROWN,
                :RELICGOLD,:RELICSILVER,:RELICSTATUE,:RELICVASE,:STARDUST,
                :STARPIECE,:STRANGESOUVENIR,:TINYMUSHROOM
               ],
         20 => [# Wings
                :CLEVERFEATHER,:GENIUSFEATHER,:HEALTHFEATHER,:MUSCLEFEATHER,
                :PRETTYFEATHER,:RESISTFEATHER,:SWIFTFEATHER
               ],
         10 => [:AIRBALLOON,:BIGROOT,:BRIGHTPOWDER,:CHOICEBAND,:CHOICESCARF,
                :CHOICESPECS,:DESTINYKNOT,:DISCOUNTCOUPON,:EXPERTBELT,:FOCUSBAND,
                :FOCUSSASH,:LAGGINGTAIL,:LEFTOVERS,:MENTALHERB,:METALPOWDER,
                :MUSCLEBAND,:POWERHERB,:QUICKPOWDER,:REAPERCLOTH,:REDCARD,
                :RINGTARGET,:SHEDSHELL,:SILKSCARF,:SILVERPOWDER,:SMOOTHROCK,
                :SOFTSAND,:SOOTHEBELL,:WHITEHERB,:WIDELENS,:WISEGLASSES,:ZOOMLENS,
                :ABILITYPATCH,:CHOICEDUMPLING,
                # Terrain seeds
                :ELECTRICSEED,:GRASSYSEED,:MISTYSEED,:PSYCHICSEED,
                # Nectar
                :PINKNECTAR,:PURPLENECTAR,:REDNECTAR,:YELLOWNECTAR,
                # Incenses
                :FULLINCENSE,:LAXINCENSE,:LUCKINCENSE,:ODDINCENSE,:PUREINCENSE,
                :ROCKINCENSE,:ROSEINCENSE,:SEAINCENSE,:WAVEINCENSE,
                # Scarves
                :BLUESCARF,:GREENSCARF,:PINKSCARF,:REDSCARF,:YELLOWSCARF
               ]
      }
    end
  
    def pbCheckFlingSuccess(user)
      @willFail = false
      @willFail = true if !user.item || !user.itemActive? || user.unlosableItem?(user.item)
      return if @willFail
      @willFail = true if user.item.is_berry? && !user.canConsumeBerry?
      return if @willFail
      return if user.item.is_mega_stone?
      return if user.item.is_TR? if Settings::MECHANICS_GENERATION >= 8
      flingableItem = false
      @flingPowers.each do |_power, items|
        next if !items.include?(user.item_id)
        flingableItem = true
        break
      end
      @willFail = true if !flingableItem
    end
  
    def pbMoveFailed?(user,targets)
      if @willFail
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbDisplayUseMessage(user)
      super
      pbCheckFlingSuccess(user)
      if !@willFail
        @battle.pbDisplay(_INTL("{1} flung its {2}!",user.pbThis,user.itemName))
      end
    end
  
    def pbNumHits(user,targets); return 1; end
  
    def pbBaseDamage(baseDmg,user,target)
      return 10 if user.item && user.item.is_berry?
      return 80 if user.item && user.item.is_mega_stone?
      if user.item && user.item.is_TR?
        return 10 if GameData::Move(user.item.move).category == 2
        return 10 if GameData::Move(user.item.move).base_damage < 10
        return GameData::Move(user.item.move).base_damage
      end
      @flingPowers.each do |power,items|
        return power if items.include?(user.item_id)
      end
      return 10
    end
  
    def pbEffectAgainstTarget(user,target)
      return if target.damageState.substitute
      return if target.hasShieldDust? && !@battle.moldBreaker
      case user.item_id
      when :POISONBARB
        target.pbPoison(user) if target.pbCanPoison?(user,false,self)
      when :TOXICORB
        target.pbPoison(user,nil,true) if target.pbCanPoison?(user,false,self)
      when :FLAMEORB, :COFFEE, :COFFEE1
        target.pbBurn(user) if target.pbCanBurn?(user,false,self)
      when :LIGHTBALL
        target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
      when :KINGSROCK, :RAZORFANG
        target.pbFlinch(user)
      else
        target.pbHeldItemTriggerCheck(user.item,true)
      end
    end
  
    def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
      # NOTE: The item is consumed even if this move was Protected against or it
      #       missed. The item is not consumed if the target was switched out by
      #       an effect like a target's Red Card.
      # NOTE: There is no item consumption animation.
      user.pbConsumeItem(true,true,false) if user.item
    end
  end
  
  
  
  #===============================================================================
  # For 5 rounds, the target cannnot use its held item, its held item has no
  # effect, and no items can be used on it. (Embargo)
  #===============================================================================
  class PokeBattle_Move_0F8 < PokeBattle_Move
    def pbFailsAgainstTarget?(user,target)
      if target.effects[PBEffects::Embargo]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
      return false
    end
  
    def pbEffectAgainstTarget(user,target)
      target.effects[PBEffects::Embargo] = 5
      @battle.pbDisplay(_INTL("{1} can't use items anymore!",target.pbThis))
    end
  end
  
  
  
  #===============================================================================
  # For 5 rounds, all held items cannot be used in any way and have no effect.
  # Held items can still change hands, but can't be thrown. (Magic Room)
  #===============================================================================
  class PokeBattle_Move_0F9 < PokeBattle_Move
    def pbEffectGeneral(user)
      if @battle.field.effects[PBEffects::MagicRoom]>0
        @battle.field.effects[PBEffects::MagicRoom] = 0
        @battle.pbDisplay(_INTL("The area returned to normal!"))
      else
        if [4,25,35,37,42].include?($fefieldeffect)
          @battle.field.effects[PBEffects::MagicRoom] = 8
        elsif $fefieldeffect == 38
          @battle.field.effects[PBEffects::MagicRoom]= 3 + @battle.pbRandom(6)
        else
          @battle.field.effects[PBEffects::MagicRoom] = 5
        end
        @battle.pbDisplay(_INTL("It created a bizarre area in which Pokémon's held items lose their effects!"))
      end
    end
  
    def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
      return if @battle.field.effects[PBEffects::MagicRoom]>0   # No animation
      super
    end
  end
  
  
  
  #===============================================================================
  # User takes recoil damage equal to 1/4 of the damage this move dealt.
  #===============================================================================
  class PokeBattle_Move_0FA < PokeBattle_RecoilMove
    def pbRecoilDamage(user,target)
      return (target.damageState.totalHPLost/4.0).round
    end
    
    def pbEffectAfterAllHits(user,target)
      return if target.damageState.unaffected
      return if !user.takesIndirectDamage?
      return if user.hasActiveAbility?(:ROCKHEAD)
      amt = pbRecoilDamage(user,target)
      amt = 1 if amt<1
      if [1,18].include?($fefieldeffect) && @id == :WILDCHARGE && user.canHeal?
        if user.pbRecoverHP(amt) > 0
          @battle.pbDisplay(_INTL("The field recharged some of {1}'s energy!",user.pbThis(true)))
        end
      else
        user.pbReduceHP(amt,false)
        @battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
        if !user.fainted?
          user.pokemon.recoil_damage += amt
        end
      end
      user.pbItemHPHealCheck
    end
    
    def healingMove?
      return [1,18].include?($fefieldeffect) && @id == :WILDCHARGE
    end
  end
  
  
  
  #===============================================================================
  # User takes recoil damage equal to 1/3 of the damage this move dealt.
  #===============================================================================
  class PokeBattle_Move_0FB < PokeBattle_RecoilMove
    def pbRecoilDamage(user,target)
      return (target.damageState.totalHPLost/3.0).round
    end
  end
  
  
  
  #===============================================================================
  # User takes recoil damage equal to 1/2 of the damage this move dealt.
  # (Head Smash, Light of Ruin)
  #===============================================================================
  class PokeBattle_Move_0FC < PokeBattle_RecoilMove
    def pbRecoilDamage(user,target)
      return (target.damageState.totalHPLost/2.0).round
    end
  end
  
  
  
  #===============================================================================
  # User takes recoil damage equal to 1/3 of the damage this move dealt.
  # May paralyze the target. (Volt Tackle)
  #===============================================================================
  class PokeBattle_Move_0FD < PokeBattle_RecoilMove
    def pbRecoilDamage(user,target)
      return (target.damageState.totalHPLost/3.0).round
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
    end
  end
  
  
  
  #===============================================================================
  # User takes recoil damage equal to 1/3 of the damage this move dealt.
  # May burn the target. (Flare Blitz)
  #===============================================================================
  class PokeBattle_Move_0FE < PokeBattle_RecoilMove
    def pbRecoilDamage(user,target)
      return (target.damageState.totalHPLost/3.0).round
    end
  
    def pbAdditionalEffect(user,target)
      return if target.damageState.substitute
      target.pbBurn(user) if target.pbCanBurn?(user,false,self)
    end
    
    def pbEffectAfterAllHits(user,target)
      return if target.damageState.unaffected
      return if !user.takesIndirectDamage?
      return if user.hasActiveAbility?(:ROCKHEAD)
      return if $fefieldeffect == 7
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
  # Starts sunny weather. (Sunny Day)
  #===============================================================================
  class PokeBattle_Move_0FF < PokeBattle_WeatherMove
    def initialize(battle,move)
      super
      @weatherType = :Sun
    end
  end
  