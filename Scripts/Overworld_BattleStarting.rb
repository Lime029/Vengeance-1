#===============================================================================
# Battle preparation
#===============================================================================
class PokemonGlobalMetadata
    attr_accessor :nextBattleBGM
    attr_accessor :nextBattleME
    attr_accessor :nextBattleCaptureME
    attr_accessor :nextBattleBack
  end
  
  
  
  class PokemonTemp
    attr_accessor :encounterTriggered
    attr_accessor :encounterType
    attr_accessor :evolutionLevels
  
    def battleRules
      @battleRules = {} if !@battleRules
      return @battleRules
    end
  
    def clearBattleRules
      self.battleRules.clear
    end
  
    def recordBattleRule(rule,var=nil)
      rules = self.battleRules
      case rule.to_s.downcase
      when "single", "1v1", "1v2", "2v1", "1v3", "3v1",
           "double", "2v2", "2v3", "3v2", "triple", "3v3"
        rules["size"] = rule.to_s.downcase
      when "canlose"                then rules["canLose"]        = true
      when "cannotlose"             then rules["canLose"]        = false
      when "canrun"                 then rules["canRun"]         = true
      when "cannotrun"              then rules["canRun"]         = false
      when "roamerflees"            then rules["roamerFlees"]    = true
      when "noexp"                  then rules["expGain"]        = false
      when "nomoney"                then rules["moneyGain"]      = false
      when "switchstyle"            then rules["switchStyle"]    = true
      when "setstyle"               then rules["switchStyle"]    = false
      when "anims"                  then rules["battleAnims"]    = true
      when "noanims"                then rules["battleAnims"]    = false
      when "terrain"
        terrain_data = GameData::BattleTerrain.try_get(var)
        rules["defaultTerrain"] = (terrain_data) ? terrain_data.id : nil
      when "weather"
        weather_data = GameData::BattleWeather.try_get(var)
        rules["defaultWeather"] = (weather_data) ? weather_data.id : nil
      when "environment", "environ"
        environment_data = GameData::Environment.try_get(var)
        rules["environment"] = (environment_data) ? environment_data.id : nil
      when "backdrop", "battleback" then rules["backdrop"]       = var
      when "base"                   then rules["base"]           = var
      when "outcome", "outcomevar"  then rules["outcomeVar"]     = var
      when "nopartner"              then rules["noPartner"]      = true
      else
        raise _INTL("Battle rule \"{1}\" does not exist.", rule)
      end
    end
  end
  
  
  
  def setBattleRule(*args)
    r = nil
    for arg in args
      if r
        $PokemonTemp.recordBattleRule(r,arg)
        r = nil
      else
        case arg.downcase
        when "terrain", "weather", "environment", "environ", "backdrop",
             "battleback", "base", "outcome", "outcomevar"
          r = arg
          next
        end
        $PokemonTemp.recordBattleRule(arg)
      end
    end
    raise _INTL("Argument {1} expected a variable after it but didn't have one.",r) if r
  end
  
  def pbNewBattleScene
    return PokeBattle_Scene.new
  end
  
  # Sets up various battle parameters and applies special rules.
  def pbPrepareBattle(battle)
    battleRules = $PokemonTemp.battleRules
    # The size of the battle, i.e. how many Pokémon on each side (default: "single")
    battle.setBattleMode(battleRules["size"]) if !battleRules["size"].nil?
    # Whether the game won't black out even if the player loses (default: false)
    battle.canLose = battleRules["canLose"] if !battleRules["canLose"].nil?
    # Whether the player can choose to run from the battle (default: true)
    battle.canRun = battleRules["canRun"] if !battleRules["canRun"].nil?
    # Whether wild Pokémon always try to run from battle (default: nil)
    battle.rules["alwaysflee"] = battleRules["roamerFlees"]
    # Whether Pokémon gain Exp/EVs from defeating/catching a Pokémon (default: true)
    battle.expGain = battleRules["expGain"] if !battleRules["expGain"].nil?
    # Whether the player gains/loses money at the end of the battle (default: true)
    battle.moneyGain = battleRules["moneyGain"] if !battleRules["moneyGain"].nil?
    # Whether the player is able to switch when an opponent's Pokémon faints
    battle.switchStyle = ($PokemonSystem.battlestyle == 0)
    battle.switchStyle = battleRules["switchStyle"] if !battleRules["switchStyle"].nil?
    battle.switchStyle = false if $game_switches[108]
    # Whether battle animations are shown
    battle.showAnims = ($PokemonSystem.battlescene == 0)
    battle.showAnims = battleRules["battleAnims"] if !battleRules["battleAnims"].nil?
    # Terrain
  =begin
    if battleRules["defaultTerrain"].nil?
      if Settings::SWSH_FOG_IN_BATTLES
        case $game_screen.weather_type
        when :Storm
          battle.defaultTerrain = :Electric
        when :Fog
          battle.defaultTerrain = :Misty
        end
      else
        battle.defaultTerrain = battleRules["defaultTerrain"]
      end
    end
  =end
    # Weather
    if battleRules["defaultWeather"].nil?
      case GameData::Weather.get($game_screen.weather_type).category
      when :Rain
        battle.defaultWeather = :Rain
      when :Hail
        battle.defaultWeather = :Hail
      when :Sandstorm
        battle.defaultWeather = :Sandstorm
      when :Sun
        if PBDayNight.isDay?
          battle.defaultWeather = :Sun
        end
      when :Fog
        battle.defaultWeather = :Fog if !Settings::SWSH_FOG_IN_BATTLES
      end
    else
      battle.defaultWeather = battleRules["defaultWeather"]
    end
    # Environment
    if battleRules["environment"].nil?
      battle.environment = pbGetEnvironment
    else
      battle.environment = battleRules["environment"]
    end
    # Backdrop graphic filename
    if !battleRules["backdrop"].nil?
      backdrop = battleRules["backdrop"]
    elsif $PokemonGlobal.nextBattleBack
      backdrop = $PokemonGlobal.nextBattleBack
    elsif $PokemonGlobal.surfing
      backdrop = "WaterSurface"   # This applies wherever you are, including in caves
    elsif GameData::MapMetadata.exists?($game_map.map_id)
      back = GameData::MapMetadata.get($game_map.map_id).battle_background
      backdrop = back if back && back != ""
    end
    $feoverride = $game_variables[44]
    $fecounter = 0
    $fefieldeffect = $feoverride
    if $feoverride > 0
      case $feoverride
      when 1
        backdrop="ElectricTerrain"
      when 2
        backdrop="GrassyTerrain"
      when 3
        backdrop="MistyTerrain"
      when 4
        backdrop="DarkCrystalCavern"
      when 5
        backdrop="Chess0"
      when 6
        backdrop="Dancefloor"
      when 7
        backdrop="Volcanic2"
      when 8
        backdrop="Swamp"
      when 9
        backdrop="Rainbow"
      when 10
        backdrop="Corrosive"
      when 11
        backdrop="CorrosiveMist"
      when 12
        backdrop="Desert"
      when 13
        backdrop="IcyCave"
      when 14
        backdrop="Rocky"
      when 15
        backdrop="Forest"
      when 16
        backdrop="VolcanicTop"
      when 17
        backdrop="Factory"
      when 18
        backdrop="Shortcircuit"
      when 19
        backdrop="Wasteland"
      when 20
        backdrop="AshenBeach"
      when 21
        backdrop="WaterSurface"
      when 22
        backdrop="Underwater"
      when 23
        backdrop="Cave"
      when 24
        backdrop="Glitch"
      when 25
        case rand(7) # Random because if supposed to set to specific one, can use background
        when 0
          backdrop="CrystalCavern0"
        when 1
          backdrop="CrystalCavern1"
          $fecounter=1
        when 2
          backdrop="CrystalCavern2"
          $fecounter=2
        when 3
          backdrop="CrystalCavern3"
          $fecounter=3
        when 4
          backdrop="CrystalCavern4"
          $fecounter=4
        when 5
          backdrop="CrystalCavern5"
          $fecounter=5
        when 6
          backdrop="CrystalCavern6"
          $fecounter=6
        end
      when 26
        backdrop="MurkwaterSurface"
      when 27
        backdrop="Mountain"
      when 28
        backdrop="SnowyMountain"
      when 29
        backdrop="Holy"
      when 30
        backdrop="Mirror"
      when 31
        backdrop="FairyTale"
      when 32
        backdrop="DragonsDen"
      when 33
        backdrop="FlowerGarden0"
      when 34
        backdrop="Starlight"
      when 35
        backdrop="NewWorld"
      when 36
        backdrop="Inverse"
      when 37
        backdrop="PsychicTerrain"
      when 38
        backdrop="Dimensional"
      when 39
        backdrop="FrozenDimensional"
      when 40
        backdrop="Haunted"
      when 41
        backdrop="CorruptedCave"
      when 42
        backdrop="BewitchedWoods"
      when 43
        backdrop="Sky"
      when 44
        backdrop="Indoor1"
      when 45
        backdrop="BoxingRing"
      when 46
        backdrop="Subzero"
      when 47
        backdrop="Jungle"
      when 48
        backdrop="Beach"
      when 49
        backdrop="XericShrubland"
      end
    end
    backdrop = "Field" if !backdrop
    # Assign Field Effect based on bg if no override
    if $feoverride == 0
      case backdrop
      when "AshenBeach"
        $fefieldeffect = 20
      when "Beach"
        $fefieldeffect = 48
      when "BewitchedWoods"
        $fefieldeffect = 42
      when "BoxingRing"
        $fefieldeffect = 45
      when "Cave", "Cave1", "Cave2"
        $fefieldeffect = 23
      when "Chess0"
        $fefieldeffect = 5
      when "Corrosive"
        $fefieldeffect = 10
      when "CorrosiveMist"
        $fefieldeffect = 11
      when "CorruptedCave"
        $fefieldeffect = 41
      when "CrystalCavern0"
        $fefieldeffect = 25
      when "CrystalCavern1"
        $fefieldeffect = 25
        $fecounter = 1
      when "CrystalCavern2"
        $fefieldeffect = 25
        $fecounter = 2
      when "CrystalCavern3"
        $fefieldeffect = 25
        $fecounter = 3
      when "CrystalCavern4"
        $fefieldeffect = 25
        $fecounter = 4
      when "CrystalCavern5"
        $fefieldeffect = 25
        $fecounter = 5
      when "CrystalCavern6"
        $fefieldeffect = 25
        $fecounter = 6
      when "Dancefloor", "PerformanceStage"
        $fefieldeffect = 6
      when "DarkCrystalCavern"
        $fefieldeffect = 4
      when "Desert"
        $fefieldeffect = 12
      when "Dimensional"
        $fefieldeffect = 38
      when "DragonsDen"
        $fefieldeffect = 32
      when "ElectricTerrain"
        $fefieldeffect = 1
      when "Factory", "Factory1", "Factory2"
        $fefieldeffect = 17
      when "FairyTale"
        $fefieldeffect = 31
      when "FlowerGarden0"
        $fefieldeffect = 33
      when "FlowerGarden1"
        $fefieldeffect = 33
        $fecounter = 1
      when "FlowerGarden2"
        $fefieldeffect = 33
        $fecounter = 2
      when "FlowerGarden3"
        $fefieldeffect = 33
        $fecounter = 3
      when "FlowerGarden4"
        $fefieldeffect = 33
        $fecounter = 4
      when "Forest", "Forest1", "Forest2"
        $fefieldeffect = 15
      when "FrozenDimensional"
        $fefieldeffect = 39
      when "Glitch"
        $fefieldeffect = 24
      when "GrassyTerrain", "Meadow"
        $fefieldeffect = 2
      when "Haunted", "Haunted1", "Haunted2"
        $fefieldeffect = 40
      when "Holy", "Holy1", "Holy2"
        $fefieldeffect = 29
      when "IcyCave", "IcyCave1"
        $fefieldeffect = 32
      when "Indoor", "Indoor1", "Indoor2", "Indoor3"
        $fefieldeffect = 44
      when "Inverse"
        $fefieldeffect = 36
      when "Jungle"
        $fefieldeffect = 47
      when "Mirror"
        $fefieldeffect = 30
      when "MistyTerrain"
        $fefieldeffect = 3
      when "Mountain"
        $fefieldeffect = 27
      when "MurkwaterSurface", "MurkwaterSurface1", "MurkwaterSurface2"
        $fefieldeffect = 26
      when "NewWorld"
        $fefieldeffect = 35
      when "PsychicTerrain", "PsychicTerrain1"
        $fefieldeffect = 37
      when "Rainbow"
        $fefieldeffect = 9
      when "Rocky"
        $fefieldeffect = 14
      when "ShortCircuit"
        $fefieldeffect = 18
      when "Sky"
        $fefieldeffect = 43
      when "SnowyMountain"
        $fefieldeffect = 28
      when "Starlight"
        $fefieldeffect = 34
      when "Subzero"
        $fefieldeffect = 46
      when "Swamp"
        $fefieldeffect = 8
      when "Underwater"
        $fefieldeffect = 22
      when "Volcanic", "Volcanic1", "Volcanic2", "Volcanic3"
        $fefieldeffect = 7
      when "VolcanicTop"
        $fefieldeffect = 16
      when "Wasteland"
        $fefieldeffect = 19
      when "WaterSurface", "WaterSurface1"
        $fefieldeffect = 21
      when "XericShrubland"
        $fefieldeffect = 49
      end
    end
    battle.backdrop = backdrop
    battle.backdropBase = backdrop
    $feinitialbg = backdrop
    $feinitial = $fefieldeffect
    $febackup = $fefieldeffect
  =begin
    # Choose a name for bases depending on environment
    if battleRules["base"].nil?
      environment_data = GameData::Environment.try_get(battle.environment)
      base = environment_data.battle_base if environment_data
    else
      base = battleRules["base"]
    end
    battle.backdropBase = base if base
  =end
    # Time of day
    if GameData::MapMetadata.exists?($game_map.map_id) &&
       GameData::MapMetadata.get($game_map.map_id).battle_environment == :Cave
      battle.time = 2   # This makes Dusk Balls work properly in caves
    elsif Settings::TIME_SHADING
      timeNow = pbGetTimeNow
      if PBDayNight.isNight?(timeNow);      battle.time = 2
      elsif PBDayNight.isEvening?(timeNow); battle.time = 1
      else;                                 battle.time = 0
      end
    end
  end
  
  # Used to determine the environment in battle, and also the form of Burmy/
  # Wormadam.
  def pbGetEnvironment
    ret = :None
    map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
    ret = map_metadata.battle_environment if map_metadata && map_metadata.battle_environment
    if $PokemonTemp.encounterType &&
       GameData::EncounterType.get($PokemonTemp.encounterType).type == :fishing
      terrainTag = $game_player.pbFacingTerrainTag
    else
      terrainTag = $game_player.terrain_tag
    end
    tile_environment = terrainTag.battle_environment
    if ret == :Forest && [:Grass, :TallGrass].include?(tile_environment)
      ret = :ForestGrass
    else
      ret = tile_environment if tile_environment
    end
    return ret
  end
  
  Events.onStartBattle += proc { |_sender|
    # Record current levels of Pokémon in party, to see if they gain a level
    # during battle and may need to evolve afterwards
    $PokemonTemp.evolutionLevels = []
    for i in 0...$Trainer.party.length
      $PokemonTemp.evolutionLevels[i] = $Trainer.party[i].level
    end
  }
  
  def pbCanDoubleBattle?
    return $PokemonGlobal.partner || $Trainer.able_pokemon_count >= 2
  end
  
  def pbCanTripleBattle?
    return true if $Trainer.able_pokemon_count >= 3
    return $PokemonGlobal.partner && $Trainer.able_pokemon_count >= 2
  end
  
  #===============================================================================
  # Start a wild battle
  #===============================================================================
  def pbWildBattleCore(*args)
    outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
    canLose    = $PokemonTemp.battleRules["canLose"] || false
    # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
    if $Trainer.able_pokemon_count == 0 || ($DEBUG && Input.press?(Input::CTRL))
      pbMessage(_INTL("SKIPPING BATTLE...")) if $Trainer.pokemon_count > 0
      pbSet(outcomeVar,1)   # Treat it as a win
      $PokemonTemp.clearBattleRules
      $PokemonGlobal.nextBattleBGM       = nil
      $PokemonGlobal.nextBattleME        = nil
      $PokemonGlobal.nextBattleCaptureME = nil
      $PokemonGlobal.nextBattleBack      = nil
      pbMEStop
      return 1   # Treat it as a win
    end
    # Record information about party Pokémon to be used at the end of battle (e.g.
    # comparing levels for an evolution check)
    Events.onStartBattle.trigger(nil)
    # Generate wild Pokémon based on the species and level
    foeParty = []
    sp = nil
    for arg in args
      if arg.is_a?(Pokemon)
        if $game_switches[60] # Random Wild Pokemon
          pkmn = pbGenerateWildPokemon(arg.species,arg.level)
          pkmn.setRandomForm(false)
          foeParty.push(pkmn)
        else
          foeParty.push(arg)
        end
      elsif arg.is_a?(Array)
        species = GameData::Species.get(arg[0]).id
        pkmn = pbGenerateWildPokemon(species,arg[1])
        foeParty.push(pkmn)
      elsif sp
        species = GameData::Species.get(sp).id
        pkmn = pbGenerateWildPokemon(species,arg)
        foeParty.push(pkmn)
        sp = nil
      else
        sp = arg
      end
    end
    raise _INTL("Expected a level after being given {1}, but one wasn't found.",sp) if sp
    # Calculate who the trainers and their party are
    playerTrainers    = [$Trainer]
    playerParty       = $Trainer.party
    playerPartyStarts = [0]
    room_for_partner = (foeParty.length > 1)
    if !room_for_partner && $PokemonTemp.battleRules["size"] &&
       !["single", "1v1", "1v2", "1v3"].include?($PokemonTemp.battleRules["size"])
      room_for_partner = true
    end
    if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && (room_for_partner ||
       !$PokemonTemp.battleRules["size"])
      ally = NPCTrainer.new($PokemonGlobal.partner[1],$PokemonGlobal.partner[0])
      ally.id    = $PokemonGlobal.partner[2]
      ally.party = $PokemonGlobal.partner[3]
      playerTrainers.push(ally)
      playerParty = []
      $Trainer.party.each { |pkmn| playerParty.push(pkmn) }
      playerPartyStarts.push(playerParty.length)
      ally.party.each { |pkmn| playerParty.push(pkmn) }
      #setBattleRule("double") if !$PokemonTemp.battleRules["size"]
      if !$PokemonTemp.battleRules["size"]
        setBattleRule("2v#{foeParty.length}") # Assumes all wild opponents are battling at once
      end
    end
    # Create the battle scene (the visual side of it)
    scene = pbNewBattleScene
    # Create the battle class (the mechanics side of it)
    battle = PokeBattle_Battle.new(scene,playerParty,foeParty,playerTrainers,nil)
    battle.party1starts = playerPartyStarts
    # Set various other properties in the battle class
    pbPrepareBattle(battle)
    $PokemonTemp.clearBattleRules
    # Perform the battle itself
    decision = 0
    pbBattleAnimation(pbGetWildBattleBGM(foeParty),(foeParty.length==1) ? 0 : 2,foeParty) {
      pbSceneStandby {
        decision = battle.pbStartBattle
      }
      pbAfterBattle(decision,canLose)
    }
    Input.update
    # Save the result of the battle in a Game Variable (1 by default)
    #    0 - Undecided or aborted
    #    1 - Player won
    #    2 - Player lost
    #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
    #    4 - Wild Pokémon was caught
    #    5 - Draw
    pbSet(outcomeVar,decision)
    return decision
  end
  
  #===============================================================================
  # Standard methods that start a wild battle of various sizes
  #===============================================================================
  # Used when walking in tall grass, hence the additional code.
  def pbWildBattle(species, level, outcomeVar=1, canRun=true, canLose=false)
    species = GameData::Species.get(species).id
    # Potentially call a different pbWildBattle-type method instead (for roaming
    # Pokémon, Safari battles, Bug Contest battles)
    handled = [nil]
    Events.onWildBattleOverride.trigger(nil,species,level,handled)
    return handled[0] if handled[0]!=nil
    # Set some battle rules
    setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
    setBattleRule("cannotRun") if !canRun
    setBattleRule("canLose") if canLose
    # Perform the battle
    decision = pbWildBattleCore(species, level)
    # Used by the Poké Radar to update/break the chain
    Events.onWildBattleEnd.trigger(nil,species,level,decision)
    # Return false if the player lost or drew the battle, and true if any other result
    return (decision!=2 && decision!=5)
  end
  
  def pbDoubleWildBattle(species1, level1, species2, level2,
                         outcomeVar=1, canRun=true, canLose=false)
    # Set some battle rules
    setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
    setBattleRule("cannotRun") if !canRun
    setBattleRule("canLose") if canLose
    #setBattleRule("double")
    # Perform the battle
    decision = pbWildBattleCore(species1, level1, species2, level2)
    # Return false if the player lost or drew the battle, and true if any other result
    return (decision!=2 && decision!=5)
  end
  
  def pbTripleWildBattle(species1, level1, species2, level2, species3, level3,
                         outcomeVar=1, canRun=true, canLose=false)
    # Set some battle rules
    setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
    setBattleRule("cannotRun") if !canRun
    setBattleRule("canLose") if canLose
    #setBattleRule("triple")
    # Perform the battle
    decision = pbWildBattleCore(species1, level1, species2, level2, species3, level3)
    # Return false if the player lost or drew the battle, and true if any other result
    return (decision!=2 && decision!=5)
  end
  
  #===============================================================================
  # Start a trainer battle
  #===============================================================================
  def pbTrainerBattleCore(*args)
    outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
    canLose    = $PokemonTemp.battleRules["canLose"] || false
    # Skip battle if the player has no able Pokémon, or if holding Ctrl in Debug mode
    if $Trainer.able_pokemon_count == 0 || ($DEBUG && Input.press?(Input::CTRL))
      pbMessage(_INTL("SKIPPING BATTLE...")) if $DEBUG
      pbMessage(_INTL("AFTER WINNING...")) if $DEBUG && $Trainer.able_pokemon_count > 0
      pbSet(outcomeVar,($Trainer.able_pokemon_count == 0) ? 0 : 1)   # Treat it as undecided/a win
      $PokemonTemp.clearBattleRules
      $PokemonGlobal.nextBattleBGM       = nil
      $PokemonGlobal.nextBattleME        = nil
      $PokemonGlobal.nextBattleCaptureME = nil
      $PokemonGlobal.nextBattleBack      = nil
      pbMEStop
      return ($Trainer.able_pokemon_count == 0) ? 0 : 1   # Treat it as undecided/a win
    end
    # Record information about party Pokémon to be used at the end of battle (e.g.
    # comparing levels for an evolution check)
    Events.onStartBattle.trigger(nil)
    # Generate trainers and their parties based on the arguments given
    foeTrainers    = []
    foeItems       = []
    foeEndSpeeches = []
    foeParty       = []
    foePartyStarts = []
    for arg in args
      if arg.is_a?(NPCTrainer)
        foeTrainers.push(arg)
        foePartyStarts.push(foeParty.length)
        arg.party.each { |pkmn| foeParty.push(pkmn) }
        foeEndSpeeches.push(arg.lose_text)
        foeItems.push(arg.items)
      elsif arg.is_a?(Array)   # [trainer type, trainer name, ID, speech (optional)]
        trainer = pbLoadTrainer(arg[0],arg[1],arg[2])
        pbMissingTrainer(arg[0],arg[1],arg[2]) if !trainer
        return 0 if !trainer
        Events.onTrainerPartyLoad.trigger(nil,trainer)
        foeTrainers.push(trainer)
        foePartyStarts.push(foeParty.length)
        trainer.party.each { |pkmn| foeParty.push(pkmn) }
        foeEndSpeeches.push(arg[3] || trainer.lose_text)
        foeItems.push(trainer.items)
      else
        raise _INTL("Expected NPCTrainer or array of trainer data, got {1}.", arg)
      end
    end
    # Calculate who the player trainer(s) and their party are
    playerTrainers    = [$Trainer]
    playerParty       = $Trainer.party
    playerPartyStarts = [0]
    room_for_partner = (foeParty.length > 1)
    if !room_for_partner && $PokemonTemp.battleRules["size"] &&
       !["single", "1v1", "1v2", "1v3"].include?($PokemonTemp.battleRules["size"])
      room_for_partner = true
    end
    if $PokemonGlobal.partner && !$PokemonTemp.battleRules["noPartner"] && (room_for_partner ||
       !$PokemonTemp.battleRules["size"])
      ally = NPCTrainer.new($PokemonGlobal.partner[1], $PokemonGlobal.partner[0])
      ally.id    = $PokemonGlobal.partner[2]
      ally.party = $PokemonGlobal.partner[3]
      playerTrainers.push(ally)
      playerParty = []
      $Trainer.party.each { |pkmn| playerParty.push(pkmn) }
      playerPartyStarts.push(playerParty.length)
      ally.party.each { |pkmn| playerParty.push(pkmn) }
      #setBattleRule("double") if !$PokemonTemp.battleRules["size"]
      if !$PokemonTemp.battleRules["size"]
        if foeParty.length == 1
          setBattleRule("2v1")
        else
          setBattleRule("2v2")
        end
      end
    end
    # Create the battle scene (the visual side of it)
    scene = pbNewBattleScene
    # Create the battle class (the mechanics side of it)
    battle = PokeBattle_Battle.new(scene,playerParty,foeParty,playerTrainers,foeTrainers)
    battle.party1starts = playerPartyStarts
    battle.party2starts = foePartyStarts
    battle.items        = foeItems
    battle.endSpeeches  = foeEndSpeeches
    # Set various other properties in the battle class
    pbPrepareBattle(battle)
    $PokemonTemp.clearBattleRules
    # End the trainer intro music
    Audio.me_stop
    # Perform the battle itself
    decision = 0
    pbBattleAnimation(pbGetTrainerBattleBGM(foeTrainers),(battle.singleBattle?) ? 1 : 3,foeTrainers) {
      pbSceneStandby {
        decision = battle.pbStartBattle
      }
      pbAfterBattle(decision,canLose)
    }
    Input.update
    # Save the result of the battle in a Game Variable (1 by default)
    #    0 - Undecided or aborted
    #    1 - Player won
    #    2 - Player lost
    #    3 - Player or wild Pokémon ran from battle, or player forfeited the match
    #    5 - Draw
    pbSet(outcomeVar,decision)
    return decision
  end
  
  #===============================================================================
  # Standard methods that start a trainer battle of various sizes
  #===============================================================================
  # Used by most trainer events, which can be positioned in such a way that
  # multiple trainer events spot the player at once. The extra code in this method
  # deals with that case and can cause a double trainer battle instead.
  def pbTrainerBattle(trainerID, trainerName, endSpeech=nil,
                      doubleBattle=false, trainerPartyID=0, canLose=false, outcomeVar=1)
    # If there is another NPC trainer who spotted the player at the same time, and
    # it is possible to have a double battle (the player has 2+ able Pokémon or
    # has a partner trainer), then record this first NPC trainer into
    # $PokemonTemp.waitingTrainer and end this method. That second NPC event will
    # then trigger and cause the battle to happen against this first trainer and
    # themselves.
    if !$PokemonTemp.waitingTrainer && pbMapInterpreterRunning? &&
       ($Trainer.able_pokemon_count > 1 ||
       ($Trainer.able_pokemon_count > 0 && $PokemonGlobal.partner))
      thisEvent = pbMapInterpreter.get_character(0)
      # Find all other triggered trainer events
      triggeredEvents = $game_player.pbTriggeredTrainerEvents([2],false)
      otherEvent = []
      for i in triggeredEvents
        next if i.id==thisEvent.id
        next if $game_self_switches[[$game_map.map_id,i.id,"A"]]
        otherEvent.push(i)
      end
      # Load the trainer's data, and call an event which might modify it
      trainer = pbLoadTrainer(trainerID,trainerName,trainerPartyID)
      pbMissingTrainer(trainerID,trainerName,trainerPartyID) if !trainer
      return false if !trainer
      Events.onTrainerPartyLoad.trigger(nil,trainer)
      # If there is exactly 1 other triggered trainer event, and this trainer has
      # 6 or fewer Pokémon, record this trainer for a double battle caused by the
      # other triggered trainer event
      if otherEvent.length == 1 && trainer.party.length <= Settings::MAX_PARTY_SIZE
        trainer.lose_text = endSpeech if endSpeech && !endSpeech.empty?
        $PokemonTemp.waitingTrainer = [trainer, thisEvent.id]
        return false
      end
    end
    # Set some battle rules
    setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
    setBattleRule("canLose") if canLose
    setBattleRule("double") if doubleBattle || $PokemonTemp.waitingTrainer
    # Perform the battle
    if $PokemonTemp.waitingTrainer
      decision = pbTrainerBattleCore($PokemonTemp.waitingTrainer[0],
         [trainerID,trainerName,trainerPartyID,endSpeech]
      )
    else
      decision = pbTrainerBattleCore([trainerID,trainerName,trainerPartyID,endSpeech])
    end
    # Finish off the recorded waiting trainer, because they have now been battled
    if decision==1 && $PokemonTemp.waitingTrainer   # Win
      pbMapInterpreter.pbSetSelfSwitch($PokemonTemp.waitingTrainer[1], "A", true)
    end
    $PokemonTemp.waitingTrainer = nil
    # Return true if the player won the battle, and false if any other result
    return (decision==1)
  end
  
  def pbDoubleTrainerBattle(trainerID1, trainerName1, trainerPartyID1, endSpeech1,
                            trainerID2, trainerName2, trainerPartyID2=0, endSpeech2=nil,
                            canLose=false, outcomeVar=1)
    # Set some battle rules
    setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
    setBattleRule("canLose") if canLose
    setBattleRule("double")
    # Perform the battle
    decision = pbTrainerBattleCore(
       [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
       [trainerID2,trainerName2,trainerPartyID2,endSpeech2]
    )
    # Return true if the player won the battle, and false if any other result
    return (decision==1)
  end
  
  def pbTripleTrainerBattle(trainerID1, trainerName1, trainerPartyID1, endSpeech1,
                            trainerID2, trainerName2, trainerPartyID2, endSpeech2,
                            trainerID3, trainerName3, trainerPartyID3=0, endSpeech3=nil,
                            canLose=false, outcomeVar=1)
    # Set some battle rules
    setBattleRule("outcomeVar",outcomeVar) if outcomeVar!=1
    setBattleRule("canLose") if canLose
    setBattleRule("triple")
    # Perform the battle
    decision = pbTrainerBattleCore(
       [trainerID1,trainerName1,trainerPartyID1,endSpeech1],
       [trainerID2,trainerName2,trainerPartyID2,endSpeech2],
       [trainerID3,trainerName3,trainerPartyID3,endSpeech3]
    )
    # Return true if the player won the battle, and false if any other result
    return (decision==1)
  end
  
  #===============================================================================
  # After battles
  #===============================================================================
  def pbAfterBattle(decision,canLose)
    $Trainer.party.each do |pkmn|
      pkmn.statusCount = 0 if pkmn.status == :POISON   # Bad poison becomes regular
      pkmn.makeUnmega
      pkmn.makeUnprimal
      if pkmn.isSpecies?(:ZACIAN) || pkmn.isSpecies?(:ZAMAZENTA) && @form == 1
        for i in 0...pkmn.moves.length
          if pkmn.moves[i].id == :IRONHEAD && pkmn.moves[i].pp < 5
            pkmn.moves[i].pp *= 3
          end
        end
      end
      newspecies = pkmn.check_evolution_after_battle
      if newspecies
        evo = PokemonEvolutionScene.new
        evo.pbStartScreen(pkmn,newspecies)
        evo.pbEvolution(false)
        evo.pbEndScreen
      end
    end
    $Trainer.heal_party if $game_switches[112]
    if $PokemonGlobal.partner
      $Trainer.heal_party
      $PokemonGlobal.partner[3].each do |pkmn|
        pkmn.heal
        pkmn.makeUnmega
        pkmn.makeUnprimal
      end
    end
    if decision==2 || decision==5   # if loss or draw
      if canLose
        $Trainer.party.each { |pkmn| pkmn.heal }
        (Graphics.frame_rate/4).times { Graphics.update }
      end
    end
    Events.onEndBattle.trigger(nil,decision,canLose)
    $game_player.straighten
  end
  
  Events.onEndBattle += proc { |_sender,e|
    decision = e[0]
    canLose  = e[1]
    if Settings::CHECK_EVOLUTION_AFTER_ALL_BATTLES || (decision!=2 && decision!=5)   # not a loss or a draw
      if $PokemonTemp.evolutionLevels
        pbEvolutionCheck($PokemonTemp.evolutionLevels)
        $PokemonTemp.evolutionLevels = nil
      end
    end
    case decision
    when 1, 4   # Win, capture
      $Trainer.pokemon_party.each do |pkmn|
        pbPickup(pkmn)
        pbHoneyGather(pkmn)
      end
    when 2, 5   # Lose, draw
      if !canLose
        $game_system.bgm_unpause
        $game_system.bgs_unpause
        pbStartOver
      end
    end
  }
  
  def pbEvolutionCheck(currentLevels)
    for i in 0...currentLevels.length
      pkmn = $Trainer.party[i]
      next if !pkmn || (pkmn.hp==0 && !Settings::CHECK_EVOLUTION_FOR_FAINTED_POKEMON)
      next if currentLevels[i] && pkmn.level==currentLevels[i]
      newSpecies = pkmn.check_evolution_on_level_up
      next if !newSpecies
      evo = PokemonEvolutionScene.new
      evo.pbStartScreen(pkmn,newSpecies)
      evo.pbEvolution
      evo.pbEndScreen
    end
  end
  
  def pbDynamicItemList(*args)
    ret = []
    for i in 0...args.length
      ret.push(i) if GameData::Item.exists?(args[i])
    end
    return ret
  end
  
  # Try to gain an item after a battle if a Pokemon has the ability Pickup.
  def pbPickup(pkmn)
    return if pkmn.egg? || !pkmn.hasAbility?(:PICKUP)
    return if pkmn.hasItem?
    return unless rand(100)<10   # 10% chance
    # Common items to find (9 items from this list are added to the pool)
    pickupList = pbDynamicItemList(
       :POTION1,
       :ANTIDOTE1,
       :SUPERPOTION1,
       :GREATBALL1,
       :REPEL,
       :ESCAPEROPE,
       :FULLHEAL1,
       :HYPERPOTION1,
       :ULTRABALL,
       :REVIVE1,
       :RARECANDY,
       :SUNSTONE,
       :MOONSTONE,
       :HEARTSCALE,
       :FULLRESTORE1,
       :MAXREVIVE1,
       :PPUP,
       :MAXELIXIR1
    )
    # Rare items to find (2 items from this list are added to the pool)
    pickupListRare = pbDynamicItemList(
       :HYPERPOTION1,
       :NUGGET,
       :KINGSROCK,
       :FULLRESTORE1,
       :ETHER1,
       :IRONBALL,
       :DESTINYKNOT,
       :ELIXIR1,
       :DESTINYKNOT,
       :LEFTOVERS,
       :DESTINYKNOT
    )
    return if pickupList.length<18
    return if pickupListRare.length<11
    # Generate a pool of items depending on the Pokémon's level
    items = []
    pkmnLevel = [100,pkmn.level].min
    itemStartIndex = (pkmnLevel-1)/10
    itemStartIndex = 0 if itemStartIndex<0
    for i in 0...9
      items.push(pickupList[itemStartIndex+i])
    end
    for i in 0...2
      items.push(pickupListRare[itemStartIndex+i])
    end
    # Probabilities of choosing each item in turn from the pool
    chances = [30,10,10,10,10,10,10,4,4,1,1]   # Needs to be 11 numbers
    chanceSum = 0
    chances.each { |c| chanceSum += c }
    # Randomly choose an item from the pool to give to the Pokémon
    rnd = rand(chanceSum)
    cumul = 0
    chances.each_with_index do |c,i|
      cumul += c
      next if rnd>=cumul
      pkmn.item = items[i]
      break
    end
  end
  
  # Try to gain a Honey item after a battle if a Pokemon has the ability Honey Gather.
  def pbHoneyGather(pkmn)
    return if !GameData::Item.exists?(:HONEY)
    return if pkmn.egg? || !pkmn.hasAbility?(:HONEYGATHER) || pkmn.hasItem?
    chance = 5 + ((pkmn.level - 1) / 10) * 5
    return unless rand(100) < chance
    pkmn.item = :HONEY
  end
  