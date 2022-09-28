module AIPreferences
    # The Game Switch which, while ON, will display all AI log messages
    AI_LOG_SWITCH = 120
    # The Game Switch which, while ON, forces the last Pokemon in an AI trainer's
    # party to be sent out last
    ACE_IS_LAST_SWITCH  = 59
      #Swagger, Flatter, Psych Up, Simple Beam, Entrainment, Skill Swap, Frost Breath, Beat Up,
      #Heal Pulse, Topsy-Turvy, Floral Healing, Instruct, Pollen Puff, Purify, Spotlight, After You
    PARTNER_FUNCTIONS = ["041","040","055","063","066","067","0A0","0C1",
          "0DF","141","16E","16B","16F","15B","16A","11D"]
  end
  
  class PokeBattle_AI
    attr_accessor(:user)
    attr_accessor(:moveChoices)
    attr_accessor(:switchChoices)
    attr_accessor(:itemChoices)
    
    def initialize(battle,user=nil,opponent=nil)
      @battle = battle
      @user = user # battler to use for trainer's knowledge about the battle
      @moveChoices = []
      @switchChoices = []
      @itemChoices = [] # { :itemID => nil, :score => 0, :targetIndex => -1 } # Party index
    end
  
    def pbAIRandom(x); return rand(x); end
    #=============================================================================
    # Decide whether the opponent should Mega Evolve their Pokémon
    #=============================================================================
    def pbEnemyShouldMegaEvolve?
      if @battle.pbCanMegaEvolve?(@user.index) # Always should if possible
        return true
      end
      return false
    end
  
    #-----------------------------------------------------------------------------
    # Z-Moves
    #-----------------------------------------------------------------------------
    def pbEnemyShouldZMove?
      return @user.moveChoice[:callMove].zMove? # Chosen move is a z-move
    end
    
    #-----------------------------------------------------------------------------
    # Ultra Burst
    #-----------------------------------------------------------------------------
    def pbEnemyShouldUltraBurst?
      if @battle.pbCanUltraBurst?(@user.index) # Always should if possible
        return true
      end
      return false
    end
  
    #=============================================================================
    # Choose an action
    #=============================================================================
    def pbDefaultChooseEnemyCommand(idxBattler)
      @user = @battle.battlers[idxBattler]
      pbEvaluateActions(idxBattler) if !@battle.opposes?(idxBattler) # Player partner action
      return if pbEnemyShouldUseItem?
      return if pbEnemyShouldWithdraw?
      return if @battle.pbAutoFightMenu(idxBattler)
      @battle.pbRegisterMegaEvolution(idxBattler) if pbEnemyShouldMegaEvolve?
      @battle.pbRegisterUltraBurst(idxBattler) if pbEnemyShouldUltraBurst?
      pbChooseEnemyZMove if pbEnemyShouldZMove?
      pbChooseMoves if !@battle.pbRegisteredZMove?(idxBattler)
    end
    
    # Determine decisions for opponents
    def setScores
      echo("\n*************** TURN #{@battle.turnCount} ***************\n") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      $time = Time.now
      for b in @battle.pbPriority(true) # Goes through all mons in order of Speed
        if !b.fainted? && @battle.opposes?(b.index)
          # Do player partner move evaluations later so it can base move on player choice
          pbEvaluateActions(b.index)
        end
      end
    end
    
    # Main action-choosing method (actions with higher scores are more likely to be chosen)
    def pbEvaluateActions(idxBattler)
      @user = @battle.battlers[idxBattler]
      echo("\n---------------------------------------------------------------") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      echo("\n[AI - #{Time.now - $time}] Performing calculations for #{@user.pbThis(true)}'s actions.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      wildBattler = (@battle.wildBattle? && @battle.opposes?(idxBattler))
      skill = 0
      if !wildBattler
        if !$PWT.nil? && $PWT.internal
          skill = 200 # Each trainer in the PWT has equal skill
        else
          skill = @battle.pbGetOwnerFromBattlerIndex(idxBattler).skill_level || 0
        end
        wildBattler = true if skill == 0 # Trainers with 0 skill make random moves like wild Pokemon
      end
      # Replace allies with switch counterpart if going to switch
      oldBattlers = @battle.battlers.clone
      @user.eachAlly do |b|
        if !@user.opposes?(b) && !b.switchChoice.nil?
          oldB = @battle.battlers[b.index]
          @battle.battlers[b.index] = pbMakeFakeBattler(b.index,@battle.pbParty(b.index)[b.switchChoice])
          echo("\n[AI - #{Time.now - $time}] #{oldB.pbThis} is going to switch into #{b.pbThis(true)}, so temporarily setting #{b.pbThis(true)} in its place.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
      end
      # Get scores and targets for each move
      @moveChoices   = []
      @switchChoices = []
      @itemChoices   = []
      @user.eachMoveWithIndex do |m,i|
        if !@battle.pbCanChooseMove?(idxBattler,i,false) # Choice items, Encore, etc.
          echo("\n[AI - #{Time.now - $time}] #{@user.pbThis} cannot choose #{m.name} as a move.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          next
        end
        if wildBattler
          pbRegisterMoveWild(i)
        else
          pbRegisterMoveTrainer(i)
          if @battle.pbCanZMove?(@user.index) && @user.pbCompatibleZMove?(m) # This move can be used as a Z-Move
            pbRegisterMoveTrainer(i,true)
          end
        end
      end
      if skill > 0 # Can't switch or use items if 0 skill
        # Find switch choices and item choices as well as their corresponding scores
        @battle.eachInTeamFromBattlerIndex(idxBattler) do |pkmn,i|
          # Don't count eggs or fainted Pokemon (will have to change this to work for Revives)
          next if !pkmn.able?
          if @battle.pbCanSwitch?(idxBattler,i)
            pbRegisterSwitch(i)
          end
          # Need to implement item usage here
        end
      end
      # Figure out useful information about the choices
      totalScore = 0
      maxScore   = 0
      (@moveChoices + @switchChoices + @itemChoices).each do |c|
        totalScore += c[:score] # Works because each array has score symbol
        maxScore = c[:score] if maxScore < c[:score]
      end
      echo("\n\n[AI - #{Time.now - $time}] The total score for all of #{@user.pbThis(true)}'s actions is #{totalScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      echo("\n[AI - #{Time.now - $time}] The maximum score out of #{@user.pbThis(true)}'s actions is #{maxScore}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      # Find the best actions and add them as preferred
      preferredActions = []
      # Start out with a random number and then weigh it based on AI level
      # Differs between rounds to give some variation/unpredictability
      if maxScore < 0 # All scores are negative (really, really bad options)
        # Negative numbers work strangely, so just set this so the best negative option is always chosen
        lowestPercentage = 1.0
          echo("\n[AI - #{Time.now - $time}] Minimum threshold determined to be 100 percent because all move scores are negative.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      else
        if skill == 0
          lowestPercentage = 0.0 # Still requires that selected options are positively scored
          echo("\n[AI - #{Time.now - $time}] Minimum threshold determined to be 0 because skill is 0.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        else
          r = 1.0 * rand(1000000) / 1000000
          lowestPercentage = r ** (15.0/skill)
          echo("\n[AI - #{Time.now - $time}] Minimum threshold determined using random number #{r} to the power of #{15.0/skill} (#{lowestPercentage}).") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
      end
      @moveChoices.each do |c|
        next if c[:score]<maxScore*lowestPercentage || !@battle.pbCanChooseMove?(idxBattler,c[:moveIndex],false) # && c[1]<200
        preferredActions.push(c)
        echo("\n[AI - #{Time.now - $time}] #{@user.pbThis}'s #{c[:realMove].name} ") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        if c[:targetIndex] >= 0 # Targeted Pokemon (Not spread move or self-target)
          echo("against #{@battle.battlers[c[:targetIndex]].pbThis(true)} ") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        end
        echo("was added as a preferred action because its score (#{c[:score]}) is at least #{lowestPercentage*100} percent of the highest score (#{maxScore}).") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      @switchChoices.each do |c| # Empty if skill is 0
        next if c[:score]<maxScore*lowestPercentage
        preferredActions.push(c)
        echo("\n[AI - #{Time.now - $time}] #{@user.pbThis} switching into #{@battle.pbParty(idxBattler)[c[:switchToIndex]].name} was added as a preferred action ") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        echo("because its score (#{c[:score]}) is at least #{lowestPercentage*100} percent of the highest score (#{maxScore}).") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      @itemChoices.each do |c| # Empty if skill is 0
        next if c[:score]<maxScore*lowestPercentage
        preferredActions.push(c)
        echo("\n[AI - #{Time.now - $time}] #{@user.pbThis} having its turn be used to give #{@battle.pbParty(idxBattler)[c[:targetIndex]].name} a(n) #{GameData::Item.get(c[:itemID]).name} was added as a preferred action ") if $game_switches[AIPreferences::AI_LOG_SWITCH]
        echo("because its score (#{c[:score]}) is at least #{lowestPercentage*100} percent of the highest score (#{maxScore}).") if $game_switches[AIPreferences::AI_LOG_SWITCH]
      end
      if preferredActions.length>0
        finalAction = preferredActions[pbAIRandom(preferredActions.length)]
        if !finalAction[:switchToIndex].nil? # Switch
          echo("\n[AI - #{Time.now - $time}] #{@user.pbThis}'s randomly chosen preferred action is switching into #{@battle.pbParty(idxBattler)[finalAction[:switchToIndex]].name}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          @user.switchChoice = finalAction[:switchToIndex]
        elsif !finalAction[:itemID].nil? # Item
          # Item usage inimplemented as of now
        else # Move
          echo("\n[AI - #{Time.now - $time}] #{@user.pbThis}'s randomly chosen preferred action is using #{finalAction[:realMove].name}") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          if finalAction[:targets].length == 1 # Move hits single target
            echo(" against #{finalAction[:targets][0].pbThis(true)}.") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          else
            echo(".") if $game_switches[AIPreferences::AI_LOG_SWITCH]
          end
          @user.moveChoice = { :callMove => finalAction[:callMove], :realMove => finalAction[:realMove], 
                               :targets => finalAction[:targets], :damages => finalAction[:damages],
                               :moveIndex => finalAction[:moveIndex], :targetIndex => finalAction[:targetIndex],
                               :user => @user, :score => finalAction[:score] }
        end
      end
      for i in 0...oldBattlers.length
        @battle.battlers[i] = oldBattlers[i]
      end
    end
  end
  