#===============================================================================
#  Pokemon World Tournament
#    by Luka S.J.
# 
#  A new (and more advanced) of my previous Pokemon World Tournament script.
#  This system is a little more sophisticated, hence more complex to use and
#  implement. Comes with a whole load of goodies like a visual battle field,
#  customizable tournaments, and Trainer Lobby. Please make sure to carefully
#  read the instructions and information on my site before using/implementing
#  this new system.
#
#  Enjoy the script, and make sure to give credit!
#  (DO NOT ALTER THE NAMES OF THE INDIVIDUAL SCRIPT SECTIONS OR YOU WILL BREAK
#   YOUR SYSTEM!)
#===============================================================================                           
#  Pokemon World Tournament (settings)
#===============================================================================                           
# This is a list of the Pokemon that cannot be used in the PWT                
BAN_LIST = [:ARTICUNO,:ZAPDOS,:MOLTRES,:MEWTWO,:MEW,:RAIKOU,:ENTEI,:SUICUNE,:HOOH,
    :LUGIA,:CELEBI,:REGIROCK,:REGICE,:REGISTEEL,:LATIAS,:LATIOS,:KYOGRE,
    :GROUDON,:RAYQUAZA,:JIRACHI,:DEOXYS,:UXIE,:MESPRIT,:AZELF,:DIALGA,:PALKIA,
    :HEATRAN,:REGIGIGAS,:GIRATINA,:CRESSELIA,:PHIONE,:MANAPHY,:DARKRAI,
    :SHAYMIN,:ARCEUS,:VICTINI,:COBALION,:TERRAKION,:VIRIZION,:TORNADUS,:THUNDURUS,
    :RESHIRAM,:ZEKROM,:LANDORUS,:KYUREM,:KELDEO,:MELOETTA,:GENESECT,:XERNEAS,
    :YVELTAL,:ZYGARDE,:DIANCIE,:HOOPA,:VOLCANION,:TAPUKOKO,:TAPULELE,:TAPUBULU,
    :TAPUFINI,:COSMOG,:COSMOEM,:SOLGALEO,:LUNALA,:NECROZMA,:MAGEARNA,:MARSHADOW,
    :ZERAORA,:MELTAN,:MELMETAL,:ZACIAN,:ZAMAZENTA,:ETERNATUS,:KUBFU,:URSHIFU,
    :ZARUDE,:REGIELEKI,:REGIDRAGO,:GLASTRIER,:SPECTRIER,:CALYREX] # All legendaries
# To edit Tournament branches please see below:

# Information pertining to the start position on the PWT stage
# Format is as following: [map_id, map_x, map_y]
PWT_MAP_DATA = [84,28,13]
# ID for the event used to move the player and opponents on the map
PWT_MOVE_EVENT = 37
# ID of the opponent event
PWT_OPP_EVENT = 35
# ID of the scoreboard event
PWT_SCORE_BOARD_EVENT = 34
# ID of the lobby trainer event
PWT_LOBBY_EVENT = 6
# ID of the event used to display an optional event if the player wins the PWT
PWT_FANFARE_EVENT = 38
#===============================================================================               
# Main PWT architecture
#-------------------------------------------------------------------------------
class AdvancedWorldTournament
attr_reader :party_bak
attr_reader :internal
attr_reader :cachedSpeech
attr_accessor :outcome
attr_accessor :beat
attr_accessor :inbattle

def paged?(name)
return true if $game_switches[106]
return $PokemonGlobal.pager.include?(name)
end

# Starts the PWT process
def initialize(viewport)
@viewport = viewport
@outcome = 0
@inbattle = false
@cachedSpeech = ""
@beat = []
@levels = []
@party_bak = []
# Turns on the PWT
@internal = true
# Backing up party
self.backupParty
# Configures the win entries of the PWT
all = self.checkFor?
$Trainer.pwt_wins = {} #if $Trainer.pwt_wins.nil? || $Trainer.pwt_wins.is_a?(Array)
for entry in all
$Trainer.pwt_wins[entry] = 0 if $Trainer.pwt_wins[entry].nil?
end
$Trainer.battle_points = 0 if $Trainer.battle_points.nil?
# Playes the introductory dialogue
self.introduction
if defined?(PokemonSave_Scene)
scene = PokemonSave_Scene.new
screen = PokemonSaveScreen.new(scene)
else
scene=PokemonSaveScene.new
screen=PokemonSave.new(scene)
end
return self.cancelEntry if !screen.pbSaveScreen
# Chooses tournament
@tournament_type = self.chooseTournament
return self.notAvailable if @tournament_type.nil?
return self.cancelEntry if !@tournament_type
# Chooses battle type
@battle_type = self.chooseBattle
return cancelEntry if !@battle_type
# Chooses new party
@modified_party = self.choosePokemon
# Generates the scoreboard
if @modified_party == "notEligible"
Kernel.pbMessage(_INTL("We're terribly sorry, but your Pokemon are not eligible for the Tournament."))
Kernel.pbMessage(_INTL(showBanList))
Kernel.pbMessage(_INTL("Please come back once your Pokemon Party has been adjusted."))
elsif !@modified_party
cancelEntry
else
# Starts tournament branch
Kernel.pbMessage(_INTL("Wonderful, you're all set."))
Kernel.pbMessage(_INTL("Good luck!"))
pbCommonEvent(8)
self.transferPlayer(*PWT_MAP_DATA)
end
end

def continue
# Continues the tournament branch
$Trainer.party.clear
$Trainer.party = @modified_party
self.setLevel
self.generateRounds(@tournament_type)
ret = self.startTournament
# Handles the tournament end and outcome
self.endFanfare if ret == "win"
@current_location.push(true)
self.transferPlayer(*@current_location)
case ret
when "win"
Kernel.pbMessage(_INTL("Congratulations on today's win."))
#Kernel.pbMessage(_INTL("For your victory you have earned 3 BP."))
Kernel.pbMessage(_INTL("No rewards are currently available."))
Kernel.pbMessage(_INTL("We hope to see you again."))
$Trainer.pwt_wins[@tournament_type] += 1
#$Trainer.battle_points += 3
self.endTournament
when "loss"
Kernel.pbMessage(_INTL("I'm sorry that you lost this tournament."))
Kernel.pbMessage(_INTL("Maybe you'll have better luck next time."))
self.cancelEntry
end
$game_variables[44] = 0
$game_switches[115] = false
end

# Ends the whole PWT process
def endTournament
$game_variables[55] = 0
self.restoreParty
self.disposeScoreboard
@internal = false
$PWT = nil
end

# Generates the main list used to manipulate the tournaments
def checkFor?(type ="list")
list = []
rows = [0]
conditions = []
return nil if self.fetchTournamentList.length < 10
catch = -1
k = 0
for i in 0...self.fetchTournamentList.length
val = self.fetchTournamentList[i]
if !val.is_a?(Array) || i == (self.fetchTournamentList.length - 1)
i += 1 if i == (self.fetchTournamentList.length - 1)
k += 1
catch = i if catch < 0
if k > 2
  k = 1
  rows.push(i - catch)
  catch = i
end
end
end
return nil if rows.length < 2
for i in 1...rows.length
next if rows[i] < 10
k = 0
for m in 0...i
k += rows[m]
end
break if self.fetchTournamentList[k].nil?
val = self.fetchTournamentList[k]
list.push(val) if val.is_a?(String)
val = self.fetchTournamentList[k + 1]
conditions.push(val)
end
return conditions.length > 0 ? conditions : nil if type == "condition"
return rows if type == "rows"
return list.length > 0 ? list : nil
end

# Generates a list of trainers for a selected tournament
def generateFromList(selected)
selected = [selected] if !selected.is_a?(Array)
list = []
rows = self.checkFor?("rows")
for sel in selected
for i in 1...rows.length
next if rows[i] < 10
k = 0
for m in 0...i
  k += rows[m]
end
break if self.fetchTournamentList[k].nil?
val = self.fetchTournamentList[k]
next if val != sel
k += 2
for m in k...(k + rows[i] - 2)
  list.push(self.fetchTournamentList[m])
end
end
end
return list.length < 8 ? nil : list
end

# Progressively generates a list of all the world leaders
def generateWorldLeaders
list = []
all = self.checkFor?
for val in all
list.push(val) if val.include?("Leaders")
end
return generateFromList(list)
end

# Heals your party
def healParty
for poke in $Trainer.party
poke.heal
end
end

# Sets all Pokemon to lv 50
def setLevel
for poke in $Trainer.party
poke.level = 50
poke.calc_stats
poke.heal
end
end

# Backs up your current party
def backupParty
@party_bak.clear
@levels.clear
for poke in $Trainer.party
@party_bak.push(poke)
@levels.push(poke.level)
end
end

# Restores your party from an existing backup
def restoreParty
$Trainer.party.clear
for i in 0...@party_bak.length
poke = @party_bak[i]
poke.level = @levels[i]
poke.calc_stats
poke.heal
$Trainer.party.push(poke)
end
end

# Outputs a message which lists all the Pokemon banned from the Tournament
def showBanList
msg = ""
=begin
for species in BAN_LIST
if species.is_a?(Numeric)
elsif species.is_a?(Symbol)
species = getConst(PBSpecies,species)
else
next
end
pkmn = PokeBattle_Pokemon.new(species,1,nil,false)
msg += "#{pkmn.name}, "
end
=end

msg += "Legendary Pokémon and Eggs are not eligible for entry in the Tournament. You must also have enough Pokémon to fill every entry space."
return msg
end

# Generates a list of choices based on available tournaments
def chooseTournament
choices = []
all = self.checkFor?
condition = self.checkFor?("condition")
world = false
for i in 0...all.length
val = all[i]
cond = condition[i]
cond = (cond == "" || eval(cond)) if cond.is_a?(String)
choices.push(val) if cond
world = true if val.include?("Leaders") && cond
world = false if val.include?("Leaders") && $Trainer.pwt_wins[val] < 1
end
choices.push("World Leaders") if world
return nil if choices.length < 1
choices.push("Cancel")
cmd = Kernel.pbMessage(_INTL("Which Tournament would you like to participate in?"),choices,choices.length)
return false if cmd == choices.length - 1
return choices[cmd]
end

# Allows the player to choose which style of battle it would like to do
def chooseBattle
#choices = ["Single","Double","Full","Sudden Death","Cancel"]
choices = ["Single","Double","Triple","Cancel"]
cmd = [nil,1,false]
cmd[0] = Kernel.pbMessage(_INTL("Which type of battle would you like to participate in?"),choices,choices.length - 1)
return false if cmd[0] == choices.length-1 # Cancel
choices = ["Normal","Rental","Cancel"]
cmd[2] = Kernel.pbMessage(_INTL("Which type of team would you like to use?"),choices,choices.length-1)
return false if cmd[2] == choices.length-1 # Cancel
cmd[2] = (cmd[2]==1) # true if rental; false otherwise
if cmd[2] # Rental
cmd[1] = 4
else
choices = ["3","4","5","6","Cancel"]
if cmd[0] == 0 # Single Battle
choices.insert(0,"2")
choices.insert(0,"1")
elsif cmd[0] == 1 # Double Battle
choices.insert(0,"2")
cmd[1] = 2
else # Triple Battle
cmd[1] = 3
end
cmd[1] += Kernel.pbMessage(_INTL("How many Pokémon would you like to battle with?"),choices,choices.length - 1)
return false if (cmd[0] == 0 && cmd[1] == choices.length || cmd[0] == 1 && cmd[1] == choices.length+1) # Cancel
end
return cmd
end

# Creates a new trainer party based on the battle type, and the Pokemon chosen to enter
def choosePokemon
ret = false
return "notEligible" if !self.partyEligible?
#length = [3,4,6,1][@battle_type]
length = @battle_type[1]
$game_variables[55] = @battle_type[1]
Kernel.pbMessage(_INTL("Please choose the Pokemon you would like to participate."))
banlist = BAN_LIST
banlist = BAN_LIST[@tournament_type] if BAN_LIST.is_a?(Hash)
ruleset = PokemonRuleSet.new
ruleset.addPokemonRule(RestrictSpecies.new(banlist))
ruleset.setNumberRange(length,length)
if @battle_type[2] # Rental
party=generateRentalParty
else
party=$Trainer.party
end
pbFadeOutIn(99999){
if defined?(PokemonParty_Scene)
 scene = PokemonParty_Scene.new
 screen = PokemonPartyScreen.new(scene,party)
else
 scene = PokemonScreen_Scene.new
 screen = PokemonScreen.new(scene,party)
end
ret = screen.pbPokemonMultipleEntryScreenEx(ruleset)
}
return ret
end

def generateRentalParty
party=[]
for i in 0...6 #@battle_type[1]
mon=generateRentalMon
j=0; loop do break unless j<1000 # Tries to prevent duplicates; maybe doesn't work?
if !party.include?(mon)
  party.push(mon)
  break
end
mon=generateRentalMon
j+=1
end
end
return party
end

def generateRentalMon
banlist = BAN_LIST
banlist = BAN_LIST[@tournament_type] if BAN_LIST.is_a?(Hash)
pool = []
GameData::Species.each { |s| pool.push(s.id) if s.form == 0 && !banlist.include?(s.id) }
species = pool[rand(pool.length)]
3.times do
break if GameData::Species.get(species).get_evolutions.length == 0 # Doesn't account for form differences
newSpecies = pool[rand(pool.length)]
species = newSpecies if !banlist.include?(newSpecies)
end
mon = Pokemon.new(GameData::Species.get(species),50,$Trainer,false)
mon.setRandomForm(false)
if rand(65535) < Settings::SHINY_POKEMON_CHANCE
mon.shiny = true
else
mon.shiny = false
end
GameData::Stat.each_main do |s|
mon.ev[s.id] = 85
end
if GameData::Species.get_species_form(species, mon.form).get_evolutions(true).length > 0 # Not fully evolved
mon.item=(:EVIOLITE)
else
mon.item=(generateRandomItem)
end
mon.trainer_reset_moves(true)
return mon
end

def generateRandomItem
items = [:WIKIBERRY,:ELEMENTALSEED,:FLAMEORB,:EXPERTBELT,:FOCUSBAND,:FIGYBERRY,
     :GANLONBERRY,:FOCUSSASH,:TELLURICSEED,:HEAVYDUTYBOOTS,:GRIPCLAW,:MENTALHERB,
     :HABANBERRY,:POWERHERB,:HARDSTONE,:WHITEHERB,:HEATROCK,:ROCKYHELMET,
     :ICYROCK,:SALACBERRY,:KASIBBERRY,:AIRBALLOON,:KEBIABERRY,:ABSORBBULB,
     :KEEBERRY,:APICOTBERRY,:KINGSROCK,:BABIRIBERRY,:LANSATBERRY,:BIGROOT,
     :LAXINCENSE,:BLACKBELT,:LEPPABERRY,:BLACKGLASSES,:LIECHIBERRY,:BLACKSLUDGE,
     :BLUNDERPOLICY,:LIGHTCLAY,:LUMBERRY,:BRIGHTPOWDER,:LUMINOUSMOSS,:CELLBATTERY,
     :MAGNET,:CHARCOAL,:MARANGABERRY,:CHARTIBERRY,:METALCOAT,:CHESTOBERRY,
     :MIRACLESEED,:CHILANBERRY,:MAGICALSEED,:CHOPLEBERRY,:MUSCLEBAND,:COBABERRY,
     :MYSTICWATER,:COLBURBERRY,:NEVERMELTICE,:DAMPROCK,:NORMALGEM,:DRAGONFANG,
     :OCCABERRY,:EJECTBUTTON,:ODDINCENSE,:EJECTPACK,:PASSHOBERRY,:METRONOME,
     :TOXICORB,:PAYAPABERRY,:TWISTEDSPOON,:PETAYABERRY,:UTILITYUMBRELLA,
     :PIXIEPLATE,:WACANBERRY,:POISONBARB,:WAVEINCENSE,:PROTECTIVEPADS,:WEAKNESSPOLICY,
     :SYNTHETICSEED,:WHITEHERB,:QUICKCLAW,:WIDELENS,:RAZORCLAW,:WISEGLASSES,
     :REDCARD,:YACHEBERRY,:RINDOBERRY,:ZOOMLENS,:ROCKINCENSE,:PERSIMBERRY,
     :ROOMSERVICE,:BINDINGBAND,:ROSEINCENSE,:BUGGEM,:ROSELIBERRY,:DARKGEM,
     :SAFETYGOGGLES,:DRAGONGEM,:SCOPELENS,:ELECTRICGEM,:SEAINCENSE,:FAIRYGEM,
     :SHARPBEAK,:FIGHTINGGEM,:SHEDSHELL,:FIREGEM,:SHELLBELL,:FLYINGGEM,:SHUCABERRY,
     :GHOSTGEM,:SILKSCARF,:GRASSGEM,:SILVERPOWDER,:GROUNDGEM,:SITRUSBERRY,
     :ICEGEM,:SMOOTHROCK,:POISONGEM,:SNOWBALL,:PSYCHICGEM,:SOFTSAND,:ROCKGEM,
     :SPELLTAG,:STEELGEM,:STARFBERRY,:WATERGEM,:TANGABERRY,:BERRYJUICE,:TERRAINEXTENDER,
     :PECHABERRY,:THROATSPRAY,:CHERIBERRY]
return items[rand(items.length)]
end

# Cancels the entry into the Tournament
def cancelEntry
self.endTournament
Kernel.pbMessage(_INTL("We hope to see you again."))
return false
end

# Checks if the party is eligible
def partyEligible?
return true if @battle_type[2] # Rental
#length = [3,4,6,1][@battle_type]
length = @battle_type[1]
count = 0
banlist = BAN_LIST
banlist = BAN_LIST[@tournament_type] if BAN_LIST.is_a?(Hash)
return false if $Trainer.party.length < length
for i in 0...$Trainer.party.length
for species in banlist
if !species.is_a?(Symbol)
  next
end
egg = $Trainer.party[i].respond_to?(:egg?) ? $Trainer.party[i].egg? : $Trainer.party[i].isEgg?
count += 1 if species != $Trainer.party[i].species && !egg
end
end
return true if count >= length
return false
end

# Method used to generate a full list of Trainers to battle
def generateRounds(selected)
@trainer_list = []
if selected == "World Leaders"
full_list = generateWorldLeaders
else
full_list = generateFromList(selected)
end
loop do
n = rand(full_list.length)
trainer = full_list[n]
full_list.delete_at(n)
@trainer_list.push(trainer)
break if @trainer_list.length > 7
end
n = rand(8)
@player_index = n
@player_index_int = @player_index
@trainer_list[n] = $Trainer.party    
@trainer_list_int = @trainer_list
end

# Methods used to generate the individual rounds
def generateRound1
self.healParty
trainer = @trainer_list[[1,0,3,2,5,4,7,6][@player_index]]
trainer = Tournament_Trainer.new(*trainer)
@cachedSpeech = trainer.winspeech
return trainer
end

def generateRound2
self.healParty
list = ["","","",""]
@player_index = @player_index/2
for i in 0...4
if i == @player_index
list[i] = $Trainer.party
else
list[i] = @trainer_list[(i*2)+rand(2)]
end
end
@trainer_list = list
trainer = @trainer_list[[1,0,3,2][@player_index]]
trainer = Tournament_Trainer.new(*trainer)
@cachedSpeech = trainer.winspeech
return trainer
end

def generateRound3
self.healParty
list = ["","","",""]
@player_index = @player_index/2
for i in 0...2
if i == @player_index
list[i] = $Trainer.party
else
list[i] = @trainer_list[(i*2)+rand(2)]
end
end
@trainer_list = list
trainer = @trainer_list[[1,0][@player_index]]
trainer = Tournament_Trainer.new(*trainer)
@cachedSpeech = trainer.winspeech
return trainer
end

def visualRound(trainer,back=false)
event = $game_map.events[PWT_OPP_EVENT]
event.character_name = GameData::TrainerType.charset_filename_brief(trainer.id)
event.refresh
if back
self.moveSwitch('D',event)
else
self.moveSwitch('B',event)
end
@miniboard.vsSequence(trainer) if !back
end

# Scoreboard visual effects
def generateScoreboard
@brdview = Viewport.new(0,-@viewport.rect.height,@viewport.rect.width,@viewport.rect.height*2)
@brdview.z = 999999
@board = Sprite.new(@brdview)
@board.bitmap = Bitmap.new(@viewport.rect.width,@viewport.rect.height)
pbSetSystemFont(@board.bitmap)
@miniboard = MiniBoard.new(@viewport)
@miniboard.update(-500,-500)
end

def displayScoreboard(trainer)
@brdview.color = Color.new(0,0,0,0)
nlist = []
for i in 0...@trainer_list.length
nlist.push(@trainer_list[i][0])
end
x = 0
y = 0
gwidth = @viewport.rect.width
gheight = @viewport.rect.height
@board.bitmap.clear
@board.bitmap.fill_rect(0,0,gwidth,gheight,Color.new(0,0,0))
@board.bitmap.blt(0,0,RPG::Cache.picture("scoreboard"),Rect.new(0,0,gwidth,gheight))
for i in 0...@trainer_list_int.length
opacity = 255
if i == @player_index_int
trname = "#{$Trainer.name}"
meta = GameData::Metadata.get_player($Trainer.character_ID)
char = pbGetPlayerCharset(meta,1)
case $Trainer.character_ID
when 0
  char = "trainer_PLAYER_M1"
when 1
  char = "trainer_PLAYER_M2"
when 2
  char = "trainer_PLAYER_M3"
when 3
  char = "trainer_PLAYER_F1"
when 4
  char = "trainer_PLAYER_F2"
when 5
  char = "trainer_PLAYER_F3"
end
bitmap = RPG::Cache.load_bitmap("Graphics/Characters/","#{char}")
else
opacity = 80 if !(nlist.include?(@trainer_list_int[i][0]))
trainer = Tournament_Trainer.new(*@trainer_list_int[i])
trname = trainer.name
bitmap = RPG::Cache.load_bitmap("Graphics/Characters/","trainer_#{trainer.id}")
end
@board.bitmap.blt(24+(gwidth-44-(bitmap.width/4))*x,24+(gheight/6)*y,bitmap,Rect.new(0,0,bitmap.width/4,bitmap.height/4),opacity)
text=[["#{trname}",34+(bitmap.width/4)+(gwidth-64-(bitmap.width/2))*x,38+(gheight/6)*y,x*1,Color.new(255,255,255),Color.new(80,80,80)]]
pbDrawTextPositions(@board.bitmap,text)
y+=1
x+=1 if y > 3
y=0 if y > 3
end
for k in 0...2
16.times do
next if @brdview.nil?
@brdview.color.alpha += 16*(k < 1 ? 1 : -1)
self.wait(1)
end
if k == 0
@brdview.rect.y += @viewport.rect.height
@brdview.rect.y = - @viewport.rect.height if @brdview.rect.y > 0
end
8.times do; Graphics.update; end
end
loop do
self.wait(1)
if Input.trigger?(Input::C)
pbSEPlay("Choose",80)
break
end
end
for k in 0...2
16.times do
next if @brdview.nil?
@brdview.color.alpha += 16*(k < 1 ? 1 : -1)
self.wait(1)
end
if k == 0
@brdview.rect.y += @viewport.rect.height
@brdview.rect.y = - @viewport.rect.height if @brdview.rect.y > 0
end
8.times do; Graphics.update; end
end
end

def disposeScoreboard
@board.dispose if @board && !@board.disposed?
@miniboard.dispose if @miniboard && !@miniboard.disposed?
@brdview.dispose if @brdview
end

def updateMiniboard
return if @miniboard.nil? || !@miniboard.respond_to?(:disposed?) || !@miniboard.respond_to?(:update)
return if !@miniboard && !@miniboard.disposed?
if $game_map.map_id == PWT_MAP_DATA[0]
event = $game_map.events[PWT_SCORE_BOARD_EVENT]
return if event.nil?
@miniboard.update(event.screen_x - 16, event.screen_y - 32)
end
end

# Creates a small introductory conversation
def introduction
Kernel.pbMessage(_INTL("Hello, and welcome to the Pokémon World Tournament!"))
Kernel.pbMessage(_INTL("This is the place where the strongest trainers from all over gather to compete."))
Kernel.pbMessage(_INTL("Before we go any further, you will need to save your progress."))
end

# Creates a small conversation if no Tournaments are available
def notAvailable
Kernel.pbMessage(_INTL("I'm terribly sorry, but it seems there are currently no competitions in which you can currently compete."))
Kernel.pbMessage(_INTL("Please come back later!"))
end

# Handles the tournament branch
def startTournament
$game_switches[115]=true
@round = 0
shouldUseRandomField = $game_variables[44] == 0
$game_variables[44] = rand(50) if shouldUseRandomField
case @battle_type[0]
when 0
setBattleRule("single")
when 1
setBattleRule("double")
when 2
setBattleRule("triple")
end
trainer = self.generateRound1
Kernel.pbMessage(_INTL("SCARLETT: Hello everyone! It is my pleasure to welcome you to the #{@tournament_type}!"))
Kernel.pbMessage(_INTL("Today we have 8 very talented contestants, and I am sure there will be plenty of intense battles for everyone to see!"))
pbCommonEvent(6)
Kernel.pbMessage(_INTL("First, let us turn our attention to the screen to see our competitors."))
self.displayScoreboard(trainer)
if trainer.name == "Scarlett"
Kernel.pbMessage(_INTL("Well, would you look at that. It seems that I'm up next!"))
pbCommonEvent(9)
self.moveSwitch('A')
else
self.moveSwitch('A')
Kernel.pbMessage(_INTL("Get ready! Our first battle will be between #{$Trainer.name} and #{trainer.name}!"))
end
self.visualRound(trainer)
$game_system.bgm_memorize
pbCueBGM(pbGetTrainerBattleBGMFromType(trainer.id),1,nil,70)
stateField
Kernel.pbMessage(_INTL("Now, without further ado, let the first match commence!"))
pbCommonEvent(7)
Kernel.pbMessage("#{trainer.name.upcase}: #{trainer.beforebattle}") if !trainer.beforebattle.nil?
pbBGMPlay(pbGetTrainerBattleBGMFromType(0),0,70) # To prevent error due to no music afterwards
if pbTrainerBattle(trainer.id,trainer.name,trainer.endspeech,false,trainer.variant,true,$PWT.outcome)
$game_switches[115]=true
$game_system.bgm_restore
case @battle_type[0]
when 0
setBattleRule("single")
when 1
setBattleRule("double")
when 2
setBattleRule("triple")
end
@round = 1
$game_variables[44] = rand(50) if shouldUseRandomField
Kernel.pbMessage("#{trainer.name.upcase}: #{trainer.afterbattle}") if !trainer.afterbattle.nil?
@beat.push(trainer)
self.visualRound(trainer,true)
pbCommonEvent(10) if trainer.name == "Scarlett"
Kernel.pbMessage(_INTL("SCARLETT: Incredible! What a fiery first round!"))
Kernel.pbMessage(_INTL("The stadium is getting heated up, and the contestants are on fire!"))
pbCommonEvent(6)
Kernel.pbMessage(_INTL("Now let's see who will be moving onto the semifinals!"))
trainer = self.generateRound2
self.displayScoreboard(trainer)
if trainer.name == "Scarlett"
Kernel.pbMessage(_INTL("Well, would you look at that. It seems that I'm up next!"))
pbCommonEvent(9)
else
Kernel.pbMessage(_INTL("The next match will be between #{$Trainer.name} and #{trainer.name}!"))
end
self.visualRound(trainer)
$game_system.bgm_memorize
pbCueBGM(pbGetTrainerBattleBGMFromType(trainer.id),1,nil,70)
stateField
Kernel.pbMessage(_INTL("Let the battle begin!"))
pbCommonEvent(7)
Kernel.pbMessage("#{trainer.name.upcase}: #{trainer.beforebattle}") if !trainer.beforebattle.nil?
pbBGMPlay(pbGetTrainerBattleBGMFromType(0),0,70) # To prevent error due to no music afterwards
if pbTrainerBattle(trainer.id,trainer.name,trainer.endspeech,false,trainer.variant,true,$PWT.outcome)
$game_switches[115]=true
$game_system.bgm_restore
case @battle_type[0]
when 0
  setBattleRule("single")
when 1
  setBattleRule("double")
when 2
  setBattleRule("triple")
end
@round = 2
$game_variables[44] = rand(50) if shouldUseRandomField
Kernel.pbMessage("#{trainer.name.upcase}: #{trainer.afterbattle}") if !trainer.afterbattle.nil?
@beat.push(trainer)
self.visualRound(trainer,true)
pbCommonEvent(10) if trainer.name == "Scarlett"
Kernel.pbMessage(_INTL("SCARLETT: The battles today have been excellent so far!"))
Kernel.pbMessage(_INTL("These trainers are really giving it everything they've got!"))
pbCommonEvent(6)
Kernel.pbMessage(_INTL("Let's direct our attention at the scoreboard one last time for the finals!"))
trainer = self.generateRound3
self.displayScoreboard(trainer)
if trainer.name == "Scarlett"
  Kernel.pbMessage(_INTL("Well, would you look at that. It seems that I'm up for the finals!"))
  pbCommonEvent(9)
else
  Kernel.pbMessage(_INTL("Alright! It's all set, the moment we've all been waiting for!"))
  Kernel.pbMessage(_INTL("The final match of this tournament will be between #{$Trainer.name} and #{trainer.name}!"))
end
self.visualRound(trainer)
$game_system.bgm_memorize
pbCueBGM(pbGetTrainerBattleBGMFromType(trainer.id),1,nil,70)
stateField
Kernel.pbMessage(_INTL("May the trainer with the most determination win!"))
pbCommonEvent(7)
Kernel.pbMessage("#{trainer.name.upcase}: #{trainer.beforebattle}") if !trainer.beforebattle.nil?
pbBGMPlay(pbGetTrainerBattleBGMFromType(0),0,70) # To prevent error due to no music afterwards
$PokemonGlobal.nextBattleBGM = "Battle PWT Final"
if pbTrainerBattle(trainer.id,trainer.name,trainer.endspeech,false,trainer.variant,true,$PWT.outcome)
  $game_switches[115]=false
  $game_system.bgm_restore
  @round = 3
  Kernel.pbMessage("#{trainer.name.upcase}: #{trainer.afterbattle}") if !trainer.afterbattle.nil?
  @beat.push(trainer)
  Kernel.pbMessage(_INTL("SCARLETT: Wow! What an amazing triumph by #{$Trainer.name}!"))
  Kernel.pbMessage(_INTL("The talent in the arena today shined bright like a flame illuminating darkness!"))
  Kernel.pbMessage(_INTL("I wish we could see this passion burn even brighter, but it looks like that's all we've got for today!"))
  Kernel.pbMessage(_INTL("Come back next time, and I'm sure the show will be just as heated as it was today!"))
  return "win"
end
end
end
return "loss"
end

def stateField
case $game_variables[44]
when 0
Kernel.pbMessage(_INTL("SCARLETT: Back to simpler times we go! Who needs to know about all these field effects and whatnot when there's no field present?"))
when 1
Kernel.pbMessage(_INTL("SCARLETT: This field will jolt you right awake if you're feeling lazy! Make sure you don't get shocked in the Electric Terrain!"))
when 2
Kernel.pbMessage(_INTL("SCARLETT: Nature sure is amazing... Just imagine the breeze lightly hitting your face while you stare at this landscape... Only the Grassy Terrain can provide such tranquility. Burns easily, too..."))
when 3
Kernel.pbMessage(_INTL("SCARLETT: These pixies are not to be messed with; one wrong move, and you'll be entrapped in a pixie ring and it's over for you! This is only possible in their natural habitat, the Misty Terrain!"))
when 4
Kernel.pbMessage(_INTL("SCARLETT: I hope no one's afraid of the dark! Let Ariadne guide you and you shan't get lost in the Dark Crystal Cavern!"))
when 5
Kernel.pbMessage(_INTL("SCARLETT: Bishop E5; Queen A3; Knight D7! Checkmate! Pay attention so that your king isn't checked on this Chess Board!"))
when 6
Kernel.pbMessage(_INTL("SCARLETT: Spotlights are in position, the curtains are now open, and the stage is yours! Who will become the star of the show here in on the Performance Stage?"))
when 7
Kernel.pbMessage(_INTL("SCARLETT: The temperature is rising up here! Careful that you don't inhale something or burn yourself; the battle in the volcano is your focus right now!"))
when 8
Kernel.pbMessage(_INTL("SCARLETT: Boggy water and foul odor; combine these and your enemy won't know what hit them! Obviously, this can only mean we're in the Swamp!"))
when 9
Kernel.pbMessage(_INTL("SCARLETT: When rain meets the sun, this marvelous phenomenon occurs! Let Iris, the goddess of rainbows, help you show your true colors here on the Rainbow Field!"))
when 10
Kernel.pbMessage(_INTL("SCARLETT: Be careful with your Steel-types here, or they'll get corroded! Bring Full Heals, because you're bound to be Poisoned on the Corrosive Field!"))
when 11
Kernel.pbMessage(_INTL("SCARLETT: Bring a gas mask with you, or you'll get poisoned by these noxious and combustible gasses in the Corrosive Mist!"))
when 12
Kernel.pbMessage(_INTL("SCARLETT: This is just too hot! Am I seeing things or is there an oasis nearby? Don't let the heat and aridity distort your perception in the Desert!"))
when 13
Kernel.pbMessage(_INTL("SCARLETT: This cave has been said to hold eons of prehistoric Pokemon's remains which are very well preserved! Just make sure that you won't be the next fossil in the Icy Cave!"))
when 14
Kernel.pbMessage(_INTL("SCARLETT: Watch your steps here, or you may hurt yourself! This field is gonna be a pain for all except Rock-types since we're on the Rocky Field!"))
when 15
Kernel.pbMessage(_INTL("SCARLETT: Oh, the greenery, such a sight to see with our own very eyes... Make no mistakes though, for danger lurks in the Forest!"))
when 16
Kernel.pbMessage(_INTL("SCARLETT: Now this... This is my favorite one! It's obviously the best field out there too, since you can barely even use Water-type moves on the Volcanic Top!"))
when 17
Kernel.pbMessage(_INTL("SCARLETT: The peak of technology stands right in front of our own very eyes! Let the machines guide your way in the Factory Field!"))
when 18
Kernel.pbMessage(_INTL("SCARLETT: Oh my, what happened here? Is everyone alright? Make sure to bring some extra batteries for the Short-Circuit Field!"))
when 19
Kernel.pbMessage(_INTL("SCARLETT: This field has suffered a lot from what we can see here. Watch your step here so you won't get your foot bitten off by whatever the hell is living in this Wasteland!"))
when 20
Kernel.pbMessage(_INTL("SCARLETT: Bring some goggles here, because once someone stirs up the ash, nobody will be able to see properly on an Ashen Beach!"))
when 21
Kernel.pbMessage(_INTL("SCARLETT: You may ask yourself how you're standing on the surface of the water, and we'll tell you not to worry about it!"))
when 22
Kernel.pbMessage(_INTL("SCARLETT: Who doesn't like to take a dive and swim with the fish? But be wary of the secrets the Underwater depths may hold!"))
when 23
Kernel.pbMessage(_INTL("SCARLETT: Did everyone pack some Repels and Escape Ropes? 'Cause we're about to go into the Cave!"))
when 24
Kernel.pbMessage(_INTL("SCARLETT: What is going on?! The field seems to be... buggin' out! It seems we aren't able to fix whatever is going on, so may luck be in your favor in this Glitch Field!"))
when 25
Kernel.pbMessage(_INTL("SCARLETT: This place is brimming with beautiful and expensive gems! Choose your moves wisely so you don't damage them in the Crystal Cavern!"))
when 26
Kernel.pbMessage(_INTL("SCARLETT: Yuck! Water and gunk, two things that I despise... If I had my way, the Murkwater Surface wouldn't be an option here at the PWT!"))
when 27
Kernel.pbMessage(_INTL("SCARLETT: Can you feel the wind blowing on your face? Make use of the air currents to boost your power on this Mountain!"))
when 28
Kernel.pbMessage(_INTL("SCARLETT: Get your fur jackets and your climbing gear, 'cause it's about to get cold! Avoid avalanches; they can seriously injure you on a Snowy Mountain!"))
when 29
Kernel.pbMessage(_INTL("SCARLETT: Pray your prayers and confess your sins, or you'll have to face heaven's verdict in this Holy Field!"))
when 30
Kernel.pbMessage(_INTL("SCARLETT: Mirror, Mirror, on the wall: Who's the strongest of them all? Be careful that you don't mistake opponents for their illusions in this Mirror Arena!"))
when 31
Kernel.pbMessage(_INTL("SCARLETT: Cursed princesses, evil queens, and noble knights. Add a speck of magic to that and you'll have a story in this Fairy Tale!"))
when 32
Kernel.pbMessage(_INTL("SCARLETT: To steal a dragon's treasure... That ought to be punishable! Be as greedy as you wish, but you'll get your just deserts in the Dragon's Den!"))
when 33
Kernel.pbMessage(_INTL("SCARLETT: What a sweet scent that drifts from these beds of beautiful flowers! But don't let this aroma fool you... Every rose has its thorn in a Flower Garden!"))
when 34
Kernel.pbMessage(_INTL("SCARLETT: The sky is filled with stars, so be sure to make a wish! ...Just be careful that you don't get a Doom Desire in the Starlight Arena!"))
when 35
Kernel.pbMessage(_INTL("SCARLETT: The vastity of Ultra Space right in front of our own very eyes! Who knows what may live in other dimensions? There may even be New Worlds waiting for us..."))
when 36
Kernel.pbMessage(_INTL("SCARLETT: What's right is now left! What's weak is now resisted! Invert your strategies trainers, for now the field becomes inverted!"))
when 37
Kernel.pbMessage(_INTL("SCARLETT: This is weird. When did we ever add this field? I swear my memory has been messed with... Anyways, make sure to not get confused on the Psychic Terrain like I have!"))
when 38
Kernel.pbMessage(_INTL("SCARLETT: Have you ever imagined what it feels to live in the void? Or to be sucked in by a black hole? The Dimensional Field will allow you to simulate that; just be careful if you want to find the answer to any of those questions..."))
when 39
Kernel.pbMessage(_INTL("SCARLETT: Many deem the Frozen Dimensional Field to be frigid and cold, but they fail to see that anger burns hotter here than anywhere..."))
when 40
Kernel.pbMessage(_INTL("SCARLETT: May whoever dares to desecrate these sacred grounds pay for it in the eternity during the afterlife! These spirits will not let you rest if you stain the Haunted Field!"))
when 41
Kernel.pbMessage(_INTL("SCARLETT: Rock-types and Poison-types are at advantage in this dangerous cave! Antidotes are your best friends if you want even a chance in the Corrupted Cave!"))
when 42
Kernel.pbMessage(_INTL("SCARLETT: They say that if you get lost in these woods, you're never going to come back home... This forest plays tricks on your mind. Befitting for the Bewitched Woods in my opinion."))
when 43
Kernel.pbMessage(_INTL("SCARLETT: Make it like Icarus and spread your wings here! Just be mindful of your capacities, or you are bound to fall from the Sky..."))
when 44
Kernel.pbMessage(_INTL("SCARLETT: This one is good for those of you who don't consider yourselves the outdoorsy type! Get cozy and enjoy your technology Indoors!"))
when 45
Kernel.pbMessage(_INTL("SCARLETT: 1... 2... 3... And it's a knock-out! Hooks, jabs, uppercuts; all is allowed in this Boxing Ring!"))
when 46
Kernel.pbMessage(_INTL("SCARLETT: ...The coldest of temperatures make fire sting hottest here on the Subzero Field. Watch out for extreme temperatures!"))
when 47
Kernel.pbMessage(_INTL("SCARLETT: Dangerous Pokémon, deadly flora, and pesky bugs! This can only mean that we're in the Jungle..."))
when 48
Kernel.pbMessage(_INTL("SCARLETT: It's everyone's favorite summer spot! The place where land meets the sea. Put on your swimsuits, 'cause we're going to the Beach!"))
when 49
Kernel.pbMessage(_INTL("SCARLETT: These shrubs haven't seen water in a hot minute, so don't even think about using this type here! Bring your Ground-types if you want an advantage in the Xeric Shrubland!"))
end
end

def transferPlayer(id,x,y,lobby =false)
@viewport.color = Color.new(0,0,0,0)
16.times do
next if @viewport.nil?
@viewport.color.alpha += 16
self.wait(1)
end
#@current_location = [$game_map.map_id,$game_player.x,$game_player.y]
@current_location = [$game_map.map_id,15,8]
$MapFactory = PokemonMapFactory.new(id)
$game_player.moveto(x, y)
$game_player.refresh
$game_player.turn_up
$game_map.autoplay
$game_map.update
if lobby
self.randLobbyGeneration
@miniboard.dispose
else
pbCommonEvent(5)
self.generateScoreboard
pbUpdateSceneMap
end
8.times do; Graphics.update; end
16.times do
next if @viewport.nil?
@viewport.color.alpha -= 16
self.wait(1)
end
end

def moveSwitch(switch = 'A',event =nil)
$game_self_switches[[PWT_MAP_DATA[0],PWT_MOVE_EVENT,switch]] = true
$game_map.need_refresh = true
loop do
break if $game_self_switches[[PWT_MAP_DATA[0],PWT_MOVE_EVENT,switch]] == false
self.wait(1)
end
end

def randLobbyGeneration
return if @beat.length < 1
return if rand(100) < 25
event = $game_map.events[PWT_LOBBY_EVENT]
trainer = @beat[rand(@beat.length)]
return if trainer.lobbyspeech.nil?
event.character_name = pbTrainerCharNameFile(trainer.id)
$Trainer.lobby_trainer = trainer
end

def endFanfare
$game_self_switches[[PWT_MAP_DATA[0],PWT_FANFARE_EVENT,'A']] = true
$game_map.need_refresh = true
loop do
break if $game_self_switches[[PWT_MAP_DATA[0],PWT_FANFARE_EVENT,'A']] == false
self.wait(1)
end
end

def wait(frames)
frames.times do
Graphics.update
Input.update
pbUpdateSceneMap
end
end
end
#-------------------------------------------------------------------------------
# Trainer objects to be used in tournaments
#-------------------------------------------------------------------------------
class Tournament_Trainer
attr_reader :id
attr_reader :name
attr_reader :endspeech
attr_reader :winspeech
attr_reader :variant
attr_reader :lobbyspeech
attr_reader :beforebattle
attr_reader :afterbattle

def initialize(*args)
trainerid, name, endspeech, winspeech, variant, speech, beforebattle, afterbattle = args
if trainerid.is_a?(Symbol)
@id = trainerid
else
raise "No valid Trainer ID has been specified"
end
@name = name
@endspeech = endspeech.nil? ? "..." : endspeech
@winspeech = winspeech.nil? ? "..." : winspeech
@variant = variant
@lobbyspeech = lobbyspeech
@beforebattle = beforebattle
@afterbattle = afterbattle
end
end
#-------------------------------------------------------------------------------
# Mini scoreboard object
#-------------------------------------------------------------------------------
class MiniBoard
attr_reader :inSequence

def initialize(viewport)
@viewport = Viewport.new(-6*32,-3*32,5*32,3*32)
@viewport.z = viewport.z - 1
@disposed = false
@inSequence = false
@index = 0

@s = {}
@s["bg"] = Sprite.new(@viewport)
@s["bg"].bitmap = RPG::Cache.picture("pwtMiniBoard_bg")
#@s["bg"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/pwtMiniBoard_bg")
@s["bg"].opacity = 0

@s["vs1"] = Sprite.new(@viewport)
@s["vs1"].bitmap = Bitmap.new(6*32,3*32)
pbSetSmallFont(@s["vs1"].bitmap)
@s["vs1"].x = 6*32

@s["vs2"] = Sprite.new(@viewport)
@s["vs2"].bitmap = Bitmap.new(6*32,3*32)
pbSetSmallFont(@s["vs2"].bitmap)
@s["vs2"].x = -6*32

@s["vs"] = Sprite.new(@viewport)
@s["vs"].bitmap = RPG::Cache.picture("pwtMiniBoard_vs")
#@s["vs"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/pwtMiniBoard_vs")
@s["vs"].ox = @s["vs"].bitmap.width/2
@s["vs"].oy = @s["vs"].bitmap.height/2
@s["vs"].x = @s["vs"].ox
@s["vs"].y = @s["vs"].oy
@s["vs"].zoom_x = 2
@s["vs"].zoom_y = 2
@s["vs"].opacity = 0

@s["over"] = Sprite.new(@viewport)
@s["over"].bitmap = RPG::Cache.picture("pwtMiniBoard_ov")
#@s["over"].bitmap = BitmapCache.load_bitmap("Graphics/Pictures/pwtMiniBoard_ov")
@s["over"].z = 50
end

def update(x, y)
@viewport.rect.x = x
@viewport.rect.y = y
@s["over"].y -= 1 if @index%4==0
@s["over"].y = 0 if @s["over"].y <= -(32*3)
@index += 1
@index = 0 if @index > 64
@s["bg"].opacity += 32 if @s["bg"].opacity < 255
if !@inSequence
@s["vs1"].x += 12 if @s["vs1"].x < 6*32
@s["vs2"].x -= 12 if @s["vs2"].x > -6*32
@s["vs"].zoom_x += 1/16.0 if @s["vs"].zoom_x < 2
@s["vs"].zoom_y += 1/16.0 if @s["vs"].zoom_y < 2
@s["vs"].opacity -= 16 if @s["vs"].opacity > 0
end
end

def dispose
pbDisposeSpriteHash(@s)
@viewport.dispose
@disposed = true
end

def disposed?
return @disposed
end

def vsSequence(trainer)
@inSequence = true
@s["vs1"].bitmap.clear
@s["vs1"].bitmap.blt(0,0,RPG::Cache.picture("pwtMiniBoard_vs1"),Rect.new(0,0,5*32,3*32))
bmp = self.fetchTrainerBmp($Trainer.trainer_type)
x = (bmp.width - 38)/2
y = (bmp.height - 38)/6
#@s["vs1"].bitmap.blt(135,13,bmp,Rect.new(x,y,38,38))
#pbDrawOutlineText(@s["vs1"].bitmap,79,59,108,26,$Trainer.name,Color.new(255,255,255),nil,1)
@s["vs1"].bitmap.blt(103,13,bmp,Rect.new(x,y,38,38))
pbDrawOutlineText(@s["vs1"].bitmap,47,59,108,26,$Trainer.name,Color.new(255,255,255),nil,1)

@s["vs2"].bitmap.clear
@s["vs2"].bitmap.blt(0,0,RPG::Cache.picture("pwtMiniBoard_vs2"),Rect.new(0,0,6*32,3*32))
bmp = self.fetchTrainerBmp(trainer.id)
x = (bmp.width - 38)/2
y = (bmp.height - 38)/6
@s["vs2"].bitmap.blt(19,44,bmp,Rect.new(x,y,38,38))
pbDrawOutlineText(@s["vs2"].bitmap,5,10,108,26,trainer.name,Color.new(255,255,255),nil,1)
16.times do
@s["vs1"].x -= 12
@s["vs2"].x += 12
@s["vs"].zoom_x -= 1/16.0
@s["vs"].zoom_y -= 1/16.0
@s["vs"].opacity += 16
pbWait(1)
end
pbWait(64)
@inSequence = false
end

def fetchTrainerBmp(trainerid)
if ![:PLAYER_M1,:PLAYER_M2,:PLAYER_M3,:PLAYER_F1,:PLAYER_F2,:PLAYER_F3].include?(trainerid)
#file = "Graphics/Pictures/PWT/#{trainerid}"
bmp0 = RPG::Cache.picture("PWT/#{trainerid.to_s}")
bmp1 = bmp0.clone
else
#file = pbPlayerSpriteFile(trainerid)
#bmp0 = BitmapCache.load_bitmap(file)
bmp0 = RPG::Cache.load_bitmap("Graphics/Trainers/","#{trainerid.to_s}")
if defined?(DynamicTrainerSprite) && defined?(TRAINERSPRITESCALE)
bmp1 = Bitmap.new(bmp0.height*TRAINERSPRITESCALE,bmp0.height*TRAINERSPRITESCALE)
bmp1.stretch_blt(Rect.new(0,0,bmp1.width,bmp1.height),bmp0,Rect.new(bmp0.width-bmp0.height,0,bmp0.height,bmp0.height))
else
bmp1 = bmp0.clone
end
end
return bmp1
end
end
#-------------------------------------------------------------------------------
# Trainer party modifier
#-------------------------------------------------------------------------------
alias pbLoadTrainer_pwt pbLoadTrainer unless defined?(pbLoadTrainer_pwt)
def pbLoadTrainer(*args)
trainer = pbLoadTrainer_pwt(*args)
return nil if trainer.nil?
return trainer if !(!$PWT.nil? && $PWT.internal)
opponent = trainer[0]
items = trainer[1]
party = trainer[2]
#length = [3,4,6,1][@battle_type]
length = @battle_type[1]
old_party = party.clone
new_party = []
count = 0
# Randomizes Team Order?
loop do
n = rand(old_party.length)
new_party.push(old_party[n])
old_party.delete_at(n)
break if new_party.length >= length
end
party = new_party.clone 
return [opponent,items,party]
end

alias pbPrepareBattle_pwt pbPrepareBattle unless defined?(pbPrepareBattle_pwt)
def pbPrepareBattle(battle)
pbPrepareBattle_pwt(battle)
if !$PWT.nil? && $PWT.internal
$PokemonGlobal.nextBattleBack = "PWT" if pbResolveBitmap(sprintf("Graphics/Battlebacks/battlebgPWT"))
$PWT.inbattle = true
battle.internalBattle = false
battle.endSpeechesWin = [$PWT.cachedSpeech]
end
end

alias pbUpdateSceneMap_pwt pbUpdateSceneMap unless defined?(pbUpdateSceneMap_pwt)
def pbUpdateSceneMap(*args)
pbUpdateSceneMap_pwt(*args)
$PWT.updateMiniboard if !$PWT.nil? && $PWT.internal && !$PWT.inbattle
end

class PokeBattle_Scene
alias pbEndBattle_pwt pbEndBattle unless self.method_defined?(:pbEndBattle_pwt)
def pbEndBattle(*args)
pbEndBattle_pwt(*args)
$PWT.inbattle = false if !$PWT.nil? && $PWT.internal && $PWT.inbattle
end
end
#-------------------------------------------------------------------------------
# PWT battle rules
#-------------------------------------------------------------------------------
class RestrictSpecies

def initialize(banlist)
@specieslist = []
for species in banlist
if species.is_a?(Symbol)
@specieslist.push(species)
end
end
end

def isSpecies?(species,specieslist)
for s in specieslist
return true if species == s
end
return false  
end

def isValid?(pokemon)
count = 0
egg = pokemon.respond_to?(:egg?) ? pokemon.egg? : pokemon.isEgg?
if isSpecies?(pokemon.species,@specieslist) && !egg
count += 1
end
return count == 0
end
end
#-------------------------------------------------------------------------------
# Extra functionality added to the Trainer class
#-------------------------------------------------------------------------------
class PokeBattle_Trainer
attr_accessor :battle_points
attr_accessor :pwt_wins
attr_accessor :lobby_trainer
end

class Game_Event
attr_accessor :interpreter
attr_accessor :page
end

# Method used to start the PWT
def startPWT
height = defined?(SCREENDUALHEIGHT) ? SCREENDUALHEIGHT : Graphics.height
viewport = Viewport.new(0,0,Graphics.width,height)
viewport.z = 100
$PWT = AdvancedWorldTournament.new(viewport)
end

def continuePWT(id =0)
$PWT.continue
end

def pwtLobbyTalk
event = $game_map.events[PWT_LOBBY_EVENT]
if event.character_name != "" && !$Trainer.lobby_trainer.nil?
Kernel.pbMessage("#{$Trainer.lobby_trainer.name.upcase}: #{$Trainer.lobby_trainer.lobbyspeech}")
#    Kernel.pbMessage(_INTL($Trainer.lobby_trainer.lobbyspeech))
end
end