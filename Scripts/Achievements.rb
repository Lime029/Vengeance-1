class PokemonGlobalMetadata
    attr_accessor :achievements
    
    def achievements
      @achievements={} if !@achievements
      return @achievements
    end
  end
  
  module Achievements
    # IDs determine the order that achievements appear in the menu.
    @achievementList={
      "STEPS"=>{
        "id"=>1,
        "name"=>"Jogger",
        "description"=>"Walk around the world.",
        "goals"=>[10000,50000,100000,500000],
        "rewards"=>["LAGGINGTAIL","QUICKCLAW","BICYCLE","OLDAMBER"],
        "rewardamount"=>[1,1,1,1]
      },
      "POKEMON_CAUGHT"=>{
        "id"=>2,
        "name"=>"Scientist",
        "description"=>"Catch Pokémon.",
        "goals"=>[10,50,100,250,500],
        "rewards"=>["POKEBALL","GREATBALL","ULTRABALL","MASTERBALL","CATCHINGCHARM"],
        "rewardamount"=>[20,30,40,5,1]
      },
      "WILD_ENCOUNTERS"=>{
        "id"=>3,
        "name"=>"Poké Maniac",
        "description"=>"Encounter Pokémon.",
        "goals"=>[250,500,1000],
        "rewards"=>["REPEL","SUPERREPEL","MAXREPEL"],
        "rewardamount"=>[30,50,100]
      },
      "TRAINER_BATTLES"=>{
        "id"=>4,
        "name"=>"Battle Girl",
        "description"=>"Partake in trainer battles.",
        "goals"=>[50,100,250,500,1000],
        "rewards"=>["RARECANDY","EXPSHARE","LUCKYEGG","EXPALL","EXPCHARM"],
        "rewardamount"=>[1,1,1,1,1]
      },
      "ITEMS_USED"=>{
        "id"=>5,
        "name"=>"Madame",
        "description"=>"Use items.",
        "goals"=>[100,250,500,1000],
        "rewards"=>["POTION","SUPERPOTION","HYPERPOTION","MAXPOTION"],
        "rewardamount"=>[10,10,10,10]
      },
      "ITEMS_SOLD"=>{
        "id"=>6,
        "name"=>"Burglar",
        "description"=>"Sell items.",
        "goals"=>[10,50,100,250,500],
        "rewards"=>["PRETTYWING","BALMMUSHROOM","PEARLSTRING","COMETSHARD","BIGNUGGET"],
        "rewardamount"=>[1,1,1,1,1]
      },
      "ITEM_BALL_ITEMS"=>{
        "id"=>7,
        "name"=>"Ruin Maniac",
        "description"=>"Find items in the overworld.",
        "goals"=>[50,100,250],
        "rewards"=>["ITEMFINDER","BOTTLECAP","GOLDBOTTLECAP"],
        "rewardamount"=>[1,1,1]
      },
      "MOVES_USED"=>{
        "id"=>8,
        "name"=>"School Kid",
        "description"=>"Use moves in battle.",
        "goals"=>[500,1000,2500,5000],
        "rewards"=>["ETHER","MAXETHER","ELIXIR","MAXELIXIR"],
        "rewardamount"=>[10,15,20,25]
      },
      "GAIN_EXPERIENCE"=>{
        "id"=>9,
        "name"=>"Rising Star",
        "description"=>"Gain experience points in battle.",
        "goals"=>[10000,50000,100000,500000,1000000],
        "rewards"=>["EXPCANDYXS","EXPCANDYS","EXPCANDYM","EXPCANDYL","EXPCANDYXL"],
        "rewardamount"=>[10,10,10,10,10]
      },
  =begin
      "EXPLOIT_FIELD"=>{
        "id"=>10,
        "name"=>"Veteran",
        "description"=>"Use moves powered up by the Field Effect.",
        "goals"=>[100,250,500],
        "rewards"=>[["ELEMENTALSEED","MAGICALSEED","TELLURICSEED","SYNTHETICSEED"],
                    ["ELEMENTALSEED","MAGICALSEED","TELLURICSEED","SYNTHETICSEED"],
                    ["ELEMENTALSEED","MAGICALSEED","TELLURICSEED","SYNTHETICSEED"]],
        "rewardamount"=>[1,5,10]
      },
  =end
      "FISHING_ENCOUNTERS"=>{
        "id"=>10,
        "name"=>"Fisherman",
        "description"=>"Encounter Pokémon by fishing.",
        "goals"=>[25,100],
        "rewards"=>["GOODROD","SUPERROD"],
        "rewardamount"=>[1,1]
      },
      "HATCH_EGGS"=>{
        "id"=>11,
        "name"=>"Pokémon Breeder",
        "description"=>"Hatch Eggs.",
        "goals"=>[25,50,100],
        "rewards"=>["OVALCHARM","EVERSTONE","DESTINYKNOT"],
        "rewardamount"=>[1,1,1]
      },
      "FIND_SHINY"=>{
        "id"=>12,
        "name"=>"Collector",
        "description"=>"Find shiny wild Pokémon.",
        "goals"=>[25],
        "rewards"=>["SHINYCHARM"],
        "rewardamount"=>[1]
      }
    }
    
    def self.list
      Achievements.fixAchievements
      return @achievementList
    end
    
    def self.fixAchievements
      @achievementList.keys.each{|a|
        if $PokemonGlobal.achievements[a].nil?
          $PokemonGlobal.achievements[a]={}
        end
        if $PokemonGlobal.achievements[a]["progress"].nil?
          $PokemonGlobal.achievements[a]["progress"]=0
        end
        if $PokemonGlobal.achievements[a]["level"].nil?
          $PokemonGlobal.achievements[a]["level"]=0
        end
      }
      $PokemonGlobal.achievements.keys.each{|k|
        if !@achievementList.keys.include? k
          $PokemonGlobal.achievements.delete(k)
        end
      }
    end
    
    def self.incrementProgress(name, amount)
      Achievements.fixAchievements
      if @achievementList.keys.include? name
        if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]["progress"].nil?
          $PokemonGlobal.achievements[name]["progress"]+=amount
          self.checkIfLevelUp(name)
          return true
        else
          return false
        end
      else
        raise "Undefined achievement: "+name.to_s
      end
    end
    
    def self.decrementProgress(name, amount)
      Achievements.fixAchievements
      if @achievementList.keys.include? name
        if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]["progress"].nil?
          $PokemonGlobal.achievements[name]["progress"]-=amount
          if $PokemonGlobal.achievements[name]["progress"]<0
            $PokemonGlobal.achievements[name]["progress"]=0
          end
          return true
        else
          return false
        end
      else
        raise "Undefined achievement: "+name.to_s
      end
    end
    
    def self.setProgress(name, amount)
      Achievements.fixAchievements
      if @achievementList.keys.include? name
        if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]["progress"].nil?
          $PokemonGlobal.achievements[name]["progress"]=amount
          if $PokemonGlobal.achievements[name]["progress"]<0
            $PokemonGlobal.achievements[name]["progress"]=0
          end
          self.checkIfLevelUp(name)
          return true
        else
          return false
        end
      else
        raise "Undefined achievement: "+name.to_s
      end
    end
    
    def self.checkIfLevelUp(name)
      Achievements.fixAchievements
      if @achievementList.keys.include? name
        if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]["progress"].nil?
          level=@achievementList[name]["goals"].length
          @achievementList[name]["goals"].each_with_index{|g,i|
            if $PokemonGlobal.achievements[name]["progress"] < g
              level=i
              break
            end
          }
          if level>$PokemonGlobal.achievements[name]["level"]
            $PokemonGlobal.achievements[name]["level"]=level
            self.queueMessage(_INTL("Achievement Reached!\n{1} Level {2}",@achievementList[name]["name"],level.to_s))
            if @achievementList[name]["rewards"][level-1].is_a?(Array)
              for r in @achievementList[name]["rewards"][level-1]
                pbWait(10)
                Kernel.pbReceiveItem(r,@achievementList[name]["rewardamount"][level-1])
              end
            else
              pbWait(10)
              Kernel.pbReceiveItem(@achievementList[name]["rewards"][level-1],@achievementList[name]["rewardamount"][level-1])
            end
            return true
          else
            return false
          end
        else
          return false
        end
      else
        raise "Undefined achievement: "+name.to_s
      end
    end
    
    def self.getCurrentGoal(name)
      Achievements.fixAchievements
      if @achievementList.keys.include? name
        if !$PokemonGlobal.achievements[name].nil? && !$PokemonGlobal.achievements[name]["progress"].nil?
          @achievementList[name]["goals"].each_with_index{|g,i|
            if $PokemonGlobal.achievements[name]["progress"] < g
              return g
            end
          }
          return nil
        else
          return 0
        end
      else
        raise "Undefined achievement: "+name.to_s
      end
    end
    
    def self.queueMessage(msg)
      if $achievementmessagequeue.nil?
        $achievementmessagequeue=[]
      end
      $achievementmessagequeue.push(msg)
    end
  end
  
  ################################################################################
  ############# PLACE THIS IN A NEW SCRIPT SECTION RIGHT ABOVE MAIN! #############
  ################################################################################
  
  ###################################
  ############# REQUIRED ############
  ###################################
  Events.onMapUpdate+=proc{|sender,e|
    if !$achievementmessagequeue.nil?
      $achievementmessagequeue.each_with_index{|m,i|
        $achievementmessagequeue.delete_at(i)
        Kernel.pbMessage(m)
      }
    end
  }
  
  ###################################
  ########### END REQUIRED ##########
  ###################################
  Events.onStepTaken+=proc{|sender,e|
    if !$PokemonGlobal.stepcount.nil?
      Achievements.setProgress("STEPS",$PokemonGlobal.stepcount)
    end
  }
  
  Events.onStartBattle+=proc {|sender,e|
    poke=e[0]
    if poke
      Achievements.incrementProgress("WILD_ENCOUNTERS",1)
    else
      Achievements.incrementProgress("TRAINER_BATTLES",1)
    end
  }
  
  Events.onEndBattle+=proc {|sender,e|
    decision = e[0]
    if decision==4
      Achievements.incrementProgress("POKEMON_CAUGHT",1)
    end
  }
  
  class PokeBattle_Battle
    alias achieve_pbUseItemOnPokemon pbUseItemOnPokemon
    def pbUseItemOnPokemon(item,pkmnIndex,userPkmn,scene)
      ret=achieve_pbUseItemOnPokemon(item,pkmnIndex,userPkmn,scene)
      if pbOwnedByPlayer?(userPkmn.index) && ret
        Achievements.incrementProgress("ITEMS_USED",1)
      end
    end
    
    alias achieve_pbUseItemOnBattler pbUseItemOnBattler
    def pbUseItemOnBattler(item,index,userPkmn,scene)
      ret=achieve_pbUseItemOnBattler(item,index,userPkmn,scene)
      if pbOwnedByPlayer?(userPkmn.index) && ret
        Achievements.incrementProgress("ITEMS_USED",1)
      end
    end
  end
  
  alias achieve_pbUseItem pbUseItem
  def pbUseItem(*args)
    ret=achieve_pbUseItem(*args)
    if ret==1 || ret==3
      Achievements.incrementProgress("ITEMS_USED",1)
    end
  end
  
  alias achieve_pbUseItemOnPokemon pbUseItemOnPokemon
  def pbUseItemOnPokemon(*args)
    ret=achieve_pbUseItemOnPokemon(*args)
    if ret
      Achievements.incrementProgress("ITEMS_USED",1)
    end
  end