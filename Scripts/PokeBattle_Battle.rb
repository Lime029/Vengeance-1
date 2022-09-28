# Results of battle:
#    0 - Undecided or aborted
#    1 - Player won
#    2 - Player lost
#    3 - Player or wild Pokémon ran from battle, or player forfeited the match
#    4 - Wild Pokémon was caught
#    5 - Draw
# Possible actions a battler can take in a round:
#    :None
#    :UseMove
#    :SwitchOut
#    :UseItem
#    :Call
#    :Run
#    :Shift
# NOTE: If you want to have more than 3 Pokémon on a side at once, you will need
#       to edit some code. Mainly this is to change/add coordinates for the
#       sprites, describe the relationships between Pokémon and trainers, and to
#       change messages. The methods that will need editing are as follows:
#           class PokeBattle_Battle
#             def setBattleMode
#             def pbGetOwnerIndexFromBattlerIndex
#             def pbGetOpposingIndicesInOrder
#             def nearBattlers?
#             def pbStartBattleSendOut
#             def pbEORShiftDistantBattlers
#             def pbCanShift?
#             def pbEndOfRoundPhase
#           class TargetMenuDisplay
#             def initialize
#           class PokemonDataBox
#             def initializeDataBoxGraphic
#           module PokeBattle_SceneConstants
#             def self.pbBattlerPosition
#             def self.pbTrainerPosition
#           class PokemonTemp
#             def recordBattleRule
#       (There is no guarantee that this list is complete.)

class PokeBattle_Battle
    attr_reader   :scene            # Scene object for this battle
    attr_reader   :peer
    attr_reader   :battleAI         # The class of the AI
    attr_reader   :field            # Effects common to the whole of a battle
    attr_reader   :sides            # Effects common to each side of a battle
    attr_reader   :positions        # Effects that apply to a battler position
    attr_reader   :battlers         # Currently active Pokémon
    attr_reader   :sideSizes        # Array of number of battlers per side
    attr_accessor :backdrop         # Filename fragment used for background graphics
    attr_accessor :backdropBase     # Filename fragment used for base graphics
    attr_accessor :time             # Time of day (0=day, 1=eve, 2=night)
    attr_accessor :environment      # Battle surroundings (for mechanics purposes)
    attr_reader   :turnCount
    attr_accessor :decision         # Decision: 0=undecided; 1=win; 2=loss; 3=escaped; 4=caught
    attr_reader   :player           # Player trainer (or array of trainers)
    attr_reader   :opponent         # Opponent trainer (or array of trainers)
    attr_accessor :items            # Items held by opponents
    attr_accessor :endSpeeches
    attr_accessor :endSpeechesWin
    attr_accessor :party1starts     # Array of start indexes for each player-side trainer's party
    attr_accessor :party2starts     # Array of start indexes for each opponent-side trainer's party
    attr_accessor :internalBattle   # Internal battle flag
    attr_accessor :debug            # Debug flag
    attr_accessor :canRun           # True if player can run from battle
    attr_accessor :canLose          # True if player won't black out if they lose
    attr_accessor :switchStyle      # Switch/Set "battle style" option
    attr_accessor :showAnims        # "Battle Effects" option
    attr_accessor :controlPlayer    # Whether player's Pokémon are AI controlled
    attr_accessor :expGain          # Whether Pokémon can gain Exp/EVs
    attr_accessor :moneyGain        # Whether the player can gain/lose money
    attr_accessor :rules
    attr_accessor :choices          # Choices made by each Pokémon this round
    attr_accessor :megaEvolution    # Battle index of each trainer's Pokémon to Mega Evolve
    attr_reader   :initialItems
    attr_reader   :recycleItems
    attr_reader   :belch
    attr_reader   :battleBond
    attr_reader   :usedInBattle     # Whether each Pokémon was used in battle (for Burmy)
    attr_reader   :successStates    # Success states
    attr_accessor :lastMoveUsed     # Last move used
    attr_accessor :lastMoveUser     # Last move user
    attr_reader   :switching        # True if during the switching phase of the round
    attr_reader   :futureSight      # True if Future Sight is hitting
    attr_reader   :endOfRound       # True during the end of round
    attr_accessor :moldBreaker      # True if Mold Breaker applies
    attr_reader   :struggle         # The Struggle move
  
    include PokeBattle_BattleCommon
  
    def pbRandom(x); return rand(x); end
  
    #=============================================================================
    # Creating the battle class
    #=============================================================================
    def initialize(scene,p1,p2,player,opponent)
      if p1.length==0
        raise ArgumentError.new(_INTL("Party 1 has no Pokémon."))
      elsif p2.length==0
        raise ArgumentError.new(_INTL("Party 2 has no Pokémon."))
      end
      @scene             = scene
      @peer              = PokeBattle_BattlePeer.create
      @battleAI          = PokeBattle_AI.new(self)
      @field             = PokeBattle_ActiveField.new    # Whole field (gravity/rooms)
      @sides             = [PokeBattle_ActiveSide.new,   # Player's side
                            PokeBattle_ActiveSide.new]   # Foe's side
      @positions         = []                            # Battler positions
      @battlers          = []
      @sideSizes         = [1,1]   # Single battle, 1v1
      @backdrop          = ""
      @backdropBase      = nil
      @time              = 0
      @environment       = :None   # e.g. Tall grass, cave, still water
      @turnCount         = 0
      @decision          = 0
      @caughtPokemon     = []
      player   = [player] if !player.nil? && !player.is_a?(Array)
      opponent = [opponent] if !opponent.nil? && !opponent.is_a?(Array)
      @player            = player     # Array of Player/NPCTrainer objects, or nil
      @opponent          = opponent   # Array of NPCTrainer objects, or nil
      @items             = nil
      @endSpeeches       = []
      @endSpeechesWin    = []
      @party1            = p1
      @party2            = p2
      @party1order       = Array.new(@party1.length) { |i| i }
      @party2order       = Array.new(@party2.length) { |i| i }
      @party1starts      = [0]
      @party2starts      = [0]
      @internalBattle    = true
      @debug             = false
      @canRun            = true
      @canLose           = false
      @switchStyle       = true
      @showAnims         = true
      @controlPlayer     = false
      @expGain           = true
      @moneyGain         = true
      @rules             = {}
      @priority          = []
      @priorityTrickRoom = false
      @choices           = []
      @megaEvolution     = [
         [-1] * (@player ? @player.length : 1),
         [-1] * (@opponent ? @opponent.length : 1)
      ]
      @initialItems      = [
         Array.new(@party1.length) { |i| (@party1[i]) ? @party1[i].item_id : nil },
         Array.new(@party2.length) { |i| (@party2[i]) ? @party2[i].item_id : nil }
      ]
      @recycleItems      = [Array.new(@party1.length, nil),   Array.new(@party2.length, nil)]
      @belch             = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
      @battleBond        = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
      @usedInBattle      = [Array.new(@party1.length, false), Array.new(@party2.length, false)]
      @successStates     = []
      @lastMoveUsed      = nil
      @lastMoveUser      = -1
      @switching         = false
      @futureSight       = false
      @endOfRound        = false
      @moldBreaker       = false
      @runCommand        = 0
      @nextPickupUse     = 0
      if GameData::Move.exists?(:STRUGGLE)
        @struggle = PokeBattle_Move.from_pokemon_move(self, Pokemon::Move.new(:STRUGGLE))
      else
        @struggle = PokeBattle_Struggle.new(self, nil)
      end
      for p in @party1
        p.startForm = p.form
      end
      for p in @party2
        p.startForm = p.form
      end
    end
  
    #=============================================================================
    # Information about the type and size of the battle
    #=============================================================================
    def wildBattle?;    return @opponent.nil?;  end
    def trainerBattle?; return !@opponent.nil?; end
  
    # Sets the number of battler slots on each side of the field independently.
    # For "1v2" names, the first number is for the player's side and the second
    # number is for the opposing side.
    def setBattleMode(mode)
      @sideSizes =
        case mode
        when "triple", "3v3" then [3, 3]
        when "3v2"           then [3, 2]
        when "3v1"           then [3, 1]
        when "2v3"           then [2, 3]
        when "double", "2v2" then [2, 2]
        when "2v1"           then [2, 1]
        when "1v3"           then [1, 3]
        when "1v2"           then [1, 2]
        else                      [1, 1]   # Single, 1v1 (default)
        end
    end
  
    def singleBattle?
      return pbSideSize(0)==1 && pbSideSize(1)==1
    end
  
    def pbSideSize(index)
      return @sideSizes[index%2]
    end
  
    def maxBattlerIndex
      return (pbSideSize(0)>pbSideSize(1)) ? (pbSideSize(0)-1)*2 : pbSideSize(1)*2-1
    end
  
    #=============================================================================
    # Trainers and owner-related methods
    #=============================================================================
    def pbPlayer; return @player[0]; end
  
    # Given a battler index, returns the index within @player/@opponent of the
    # trainer that controls that battler index.
    # NOTE: You shouldn't ever have more trainers on a side than there are battler
    #       positions on that side. This method doesn't account for if you do.
    def pbGetOwnerIndexFromBattlerIndex(idxBattler)
      trainer = (opposes?(idxBattler)) ? @opponent : @player
      return 0 if !trainer
      case trainer.length
      when 2
        n = pbSideSize(idxBattler%2)
        return [0,0,1][idxBattler/2] if n==3
        return idxBattler/2   # Same as [0,1][idxBattler/2], i.e. 2 battler slots
      when 3
        return idxBattler/2
      end
      return 0
    end
  
    def pbGetOwnerFromBattlerIndex(idxBattler)
      idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      return (opposes?(idxBattler)) ? @opponent[idxTrainer] : @player[idxTrainer]
    end
  
    def pbGetOwnerIndexFromPartyIndex(idxBattler,idxParty)
      ret = -1
      pbPartyStarts(idxBattler).each_with_index do |start,i|
        break if start>idxParty
        ret = i
      end
      return ret
    end
  
    # Only used for the purpose of an error message when one trainer tries to
    # switch another trainer's Pokémon.
    def pbGetOwnerFromPartyIndex(idxBattler,idxParty)
      idxTrainer = pbGetOwnerIndexFromPartyIndex(idxBattler,idxParty)
      return (opposes?(idxBattler)) ? @opponent[idxTrainer] : @player[idxTrainer]
    end
  
    def pbGetOwnerName(idxBattler)
      idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      return @opponent[idxTrainer].full_name if opposes?(idxBattler)   # Opponent
      return @player[idxTrainer].full_name if idxTrainer>0   # Ally trainer
      return @player[idxTrainer].name   # Player
    end
  
    def pbGetOwnerItems(idxBattler)
      return [] if !@items || !opposes?(idxBattler)
      return @items[pbGetOwnerIndexFromBattlerIndex(idxBattler)]
    end
  
    # Returns whether the battler in position idxBattler is owned by the same
    # trainer that owns the Pokémon in party slot idxParty. This assumes that
    # both the battler position and the party slot are from the same side.
    def pbIsOwner?(idxBattler,idxParty)
      idxTrainer1 = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      idxTrainer2 = pbGetOwnerIndexFromPartyIndex(idxBattler,idxParty)
      return idxTrainer1==idxTrainer2
    end
  
    def pbOwnedByPlayer?(idxBattler)
      return false if opposes?(idxBattler)
      return pbGetOwnerIndexFromBattlerIndex(idxBattler)==0
    end
  
    # Returns the number of Pokémon positions controlled by the given trainerIndex
    # on the given side of battle.
    def pbNumPositions(side,idxTrainer)
      ret = 0
      for i in 0...pbSideSize(side)
        t = pbGetOwnerIndexFromBattlerIndex(i*2+side)
        next if t!=idxTrainer
        ret += 1
      end
      return ret
    end
  
    #=============================================================================
    # Get party information (counts all teams on the same side)
    #=============================================================================
    def pbParty(idxBattler)
      return (opposes?(idxBattler)) ? @party2 : @party1
    end
  
    def pbOpposingParty(idxBattler)
      return (opposes?(idxBattler)) ? @party1 : @party2
    end
  
    def pbPartyOrder(idxBattler)
      return (opposes?(idxBattler)) ? @party2order : @party1order
    end
  
    def pbPartyStarts(idxBattler)
      return (opposes?(idxBattler)) ? @party2starts : @party1starts
    end
  
    # Returns the player's team in its display order. Used when showing the party
    # screen.
    def pbPlayerDisplayParty(idxBattler=0)
      partyOrders = pbPartyOrder(idxBattler)
      idxStart, _idxEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
      ret = []
      eachInTeamFromBattlerIndex(idxBattler) { |pkmn,i| ret[partyOrders[i]-idxStart] = pkmn }
      return ret
    end
  
    def pbAbleCount(idxBattler=0)
      party = pbParty(idxBattler)
      count = 0
      party.each { |pkmn| count += 1 if pkmn && pkmn.able? }
      return count
    end
  
    def pbAbleNonActiveCount(idxBattler=0)
      party = pbParty(idxBattler)
      inBattleIndices = []
      eachSameSideBattler(idxBattler) { |b| inBattleIndices.push(b.pokemonIndex) }
      count = 0
      party.each_with_index do |pkmn,idxParty|
        next if !pkmn || !pkmn.able?
        next if inBattleIndices.include?(idxParty)
        count += 1
      end
      return count
    end
  
    def pbAllFainted?(idxBattler=0)
      return pbAbleCount(idxBattler)==0
    end
  
    # For the given side of the field (0=player's, 1=opponent's), returns an array
    # containing the number of able Pokémon in each team.
    def pbAbleTeamCounts(side)
      party = pbParty(side)
      partyStarts = pbPartyStarts(side)
      ret = []
      idxTeam = -1
      nextStart = 0
      party.each_with_index do |pkmn,i|
        if i>=nextStart
          idxTeam += 1
          nextStart = (idxTeam<partyStarts.length-1) ? partyStarts[idxTeam+1] : party.length
        end
        next if !pkmn || !pkmn.able?
        ret[idxTeam] = 0 if !ret[idxTeam]
        ret[idxTeam] += 1
      end
      return ret
    end
  
    #=============================================================================
    # Get team information (a team is only the Pokémon owned by a particular
    # trainer)
    #=============================================================================
    def pbTeamIndexRangeFromBattlerIndex(idxBattler)
      partyStarts = pbPartyStarts(idxBattler)
      idxTrainer = pbGetOwnerIndexFromBattlerIndex(idxBattler)
      idxPartyStart = partyStarts[idxTrainer]
      idxPartyEnd   = (idxTrainer<partyStarts.length-1) ? partyStarts[idxTrainer+1] : pbParty(idxBattler).length
      return idxPartyStart, idxPartyEnd
    end
  
    def pbTeamLengthFromBattlerIndex(idxBattler)
      idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
      return idxPartyEnd-idxPartyStart
    end
  
    def eachInTeamFromBattlerIndex(idxBattler)
      party = pbParty(idxBattler)
      idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
      party.each_with_index { |pkmn,i| yield pkmn,i if pkmn && i>=idxPartyStart && i<idxPartyEnd }
    end
  
    def eachInTeam(side,idxTrainer)
      party       = pbParty(side)
      partyStarts = pbPartyStarts(side)
      idxPartyStart = partyStarts[idxTrainer]
      idxPartyEnd   = (idxTrainer<partyStarts.length-1) ? partyStarts[idxTrainer+1] : party.length
      party.each_with_index { |pkmn,i| yield pkmn,i if pkmn && i>=idxPartyStart && i<idxPartyEnd }
    end
  
    # Used for Illusion.
    # NOTE: This cares about the temporary rearranged order of the team. That is,
    #       if you do some switching, the last Pokémon in the team could change
    #       and the Illusion could be a different Pokémon.
    def pbLastInTeam(idxBattler)
      party       = pbParty(idxBattler)
      partyOrders = pbPartyOrder(idxBattler)
      idxPartyStart, idxPartyEnd = pbTeamIndexRangeFromBattlerIndex(idxBattler)
      ret = -1
      party.each_with_index do |pkmn,i|
        next if i < idxPartyStart || i >= idxPartyEnd   # Check the team only
        next if !pkmn || !pkmn.able?   # Can't copy a non-fainted Pokémon or egg
        ret = i if ret < 0 || partyOrders[i] > partyOrders[ret]
      end
      return ret
    end
  
    # Used to calculate money gained/lost after winning/losing a battle.
    def pbMaxLevelInTeam(side,idxTrainer)
      ret = 1
      eachInTeam(side,idxTrainer) do |pkmn,_i|
        ret = pkmn.level if pkmn.level>ret
      end
      return ret
    end
  
    #=============================================================================
    # Iterate through battlers
    #=============================================================================
    def eachBattler
      @battlers.each { |b| yield b if b && !b.fainted? }
    end
  
    def eachSameSideBattler(idxBattler=0)
      idxBattler = idxBattler.index if idxBattler.respond_to?("index")
      @battlers.each { |b| yield b if b && !b.fainted? && !b.opposes?(idxBattler) }
    end
  
    def eachOtherSideBattler(idxBattler=0)
      idxBattler = idxBattler.index if idxBattler.respond_to?("index")
      @battlers.each { |b| yield b if b && !b.fainted? && b.opposes?(idxBattler) }
    end
  
    def pbSideBattlerCount(idxBattler=0)
      ret = 0
      eachSameSideBattler(idxBattler) { |_b| ret += 1 }
      return ret
    end
  
    def pbOpposingBattlerCount(idxBattler=0)
      ret = 0
      eachOtherSideBattler(idxBattler) { |_b| ret += 1 }
      return ret
    end
  
    # This method only counts the player's Pokémon, not a partner trainer's.
    def pbPlayerBattlerCount
      ret = 0
      eachSameSideBattler { |b| ret += 1 if b.pbOwnedByPlayer? }
      return ret
    end
  
    def pbCheckGlobalAbility(abil)
      ret = []
      eachBattler { |b| ret.push(b) if b.hasActiveAbility?(abil) }
      return (ret == []) ? nil : ret
    end
  
    def pbCheckOpposingAbility(abil,idxBattler=0,nearOnly=false)
      eachOtherSideBattler(idxBattler) do |b|
        next if nearOnly && !b.near?(idxBattler)
        return b if b.hasActiveAbility?(abil)
      end
      return nil
    end
  
    # Given a battler index, and using battle side sizes, returns an array of
    # battler indices from the opposing side that are in order of most "opposite".
    # Used when choosing a target and pressing up/down to move the cursor to the
    # opposite side, and also when deciding which target to select first for some
    # moves.
    def pbGetOpposingIndicesInOrder(idxBattler)
      case pbSideSize(0)
      when 1
        case pbSideSize(1)
        when 1   # 1v1 single
          return [0] if opposes?(idxBattler)
          return [1]
        when 2   # 1v2
          return [0] if opposes?(idxBattler)
          return [3,1]
        when 3   # 1v3
          return [0] if opposes?(idxBattler)
          return [3,5,1]
        end
      when 2
        case pbSideSize(1)
        when 1   # 2v1
          return [0,2] if opposes?(idxBattler)
          return [1]
        when 2   # 2v2 double
          return [[3,1],[2,0],[1,3],[0,2]][idxBattler]
        when 3   # 2v3
          return [[5,3,1],[2,0],[3,1,5]][idxBattler] if idxBattler<3
          return [0,2]
        end
      when 3
        case pbSideSize(1)
        when 1   # 3v1
          return [2,0,4] if opposes?(idxBattler)
          return [1]
        when 2   # 3v2
          return [[3,1],[2,4,0],[3,1],[2,0,4],[1,3]][idxBattler]
        when 3   # 3v3 triple
          return [[5,3,1],[4,2,0],[3,5,1],[2,0,4],[1,3,5],[0,2,4]][idxBattler]
        end
      end
      return [idxBattler]
    end
  
    #=============================================================================
    # Comparing the positions of two battlers
    #=============================================================================
    def opposes?(idxBattler1,idxBattler2=0)
      idxBattler1 = idxBattler1.index if idxBattler1.respond_to?("index")
      idxBattler2 = idxBattler2.index if idxBattler2.respond_to?("index")
      return (idxBattler1&1)!=(idxBattler2&1)
    end
  
    def nearBattlers?(idxBattler1,idxBattler2)
      return false if idxBattler1==idxBattler2
      return true if pbSideSize(0)<=2 && pbSideSize(1)<=2
      # Get all pairs of battler positions that are not close to each other
      pairsArray = [[0,4],[1,5]]   # Covers 3v1 and 1v3
      case pbSideSize(0)
      when 3
        case pbSideSize(1)
        when 3   # 3v3 (triple)
          pairsArray.push([0,1])
          pairsArray.push([4,5])
        when 2   # 3v2
          pairsArray.push([0,1])
          pairsArray.push([3,4])
        end
      when 2       # 2v3
        pairsArray.push([0,1])
        pairsArray.push([2,5])
      end
      # See if any pair matches the two battlers being assessed
      pairsArray.each do |pair|
        return false if pair.include?(idxBattler1) && pair.include?(idxBattler2)
      end
      return true
    end
  
    #=============================================================================
    # Altering a party or rearranging battlers
    #=============================================================================
    def pbRemoveFromParty(idxBattler,idxParty)
      party = pbParty(idxBattler)
      # Erase the Pokémon from the party
      party[idxParty] = nil
      # Rearrange the display order of the team to place the erased Pokémon last
      # in it (to avoid gaps)
      partyOrders = pbPartyOrder(idxBattler)
      partyStarts = pbPartyStarts(idxBattler)
      idxTrainer = pbGetOwnerIndexFromPartyIndex(idxBattler,idxParty)
      idxPartyStart = partyStarts[idxTrainer]
      idxPartyEnd   = (idxTrainer<partyStarts.length-1) ? partyStarts[idxTrainer+1] : party.length
      origPartyPos = partyOrders[idxParty]   # Position of erased Pokémon initially
      partyOrders[idxParty] = idxPartyEnd   # Put erased Pokémon last in the team
      party.each_with_index do |_pkmn,i|
        next if i<idxPartyStart || i>=idxPartyEnd   # Only check the team
        next if partyOrders[i]<origPartyPos   # Appeared before erased Pokémon
        partyOrders[i] -= 1   # Appeared after erased Pokémon; bump it up by 1
      end
    end
  
    def pbSwapBattlers(idxA,idxB)
      return false if !@battlers[idxA] || !@battlers[idxB]
      # Can't swap if battlers aren't owned by the same trainer
      return false if opposes?(idxA,idxB)
      return false if pbGetOwnerIndexFromBattlerIndex(idxA)!=pbGetOwnerIndexFromBattlerIndex(idxB)
      @battlers[idxA],       @battlers[idxB]       = @battlers[idxB],       @battlers[idxA]
      @battlers[idxA].index, @battlers[idxB].index = @battlers[idxB].index, @battlers[idxA].index
      @choices[idxA],        @choices[idxB]        = @choices[idxB],        @choices[idxA]
      @scene.pbSwapBattlerSprites(idxA,idxB)
      # Swap the target of any battlers' effects that point at either of the
      # swapped battlers, to ensure they still point at the correct target
      # NOTE: LeechSeed is not swapped, because drained HP goes to whichever
      #       Pokémon is in the position that Leech Seed was used from.
      # NOTE: PerishSongUser doesn't need to change, as it's only used to
      #       determine which side the Perish Song user was on, and a battler
      #       can't change sides.
      effectsToSwap = [PBEffects::Attract,
                       PBEffects::BideTarget,
                       PBEffects::CounterTarget,
                       PBEffects::LockOnPos,
                       PBEffects::MeanLook,
                       PBEffects::MirrorCoatTarget,
                       PBEffects::SkyDrop,
                       PBEffects::TrappingUser]
      eachBattler do |b|
        for i in effectsToSwap
          next if b.effects[i]!=idxA && b.effects[i]!=idxB
          b.effects[i] = (b.effects[i]==idxA) ? idxB : idxA
        end
      end
      return true
    end
  
    #=============================================================================
    #
    #=============================================================================
    # Returns the battler representing the Pokémon at index idxParty in its party,
    # on the same side as a battler with battler index of idxBattlerOther.
    def pbFindBattler(idxParty,idxBattlerOther=0)
      eachSameSideBattler(idxBattlerOther) { |b| return b if b.pokemonIndex==idxParty }
      return nil
    end
  
    # Only used for Wish, as the Wishing Pokémon will no longer be in battle.
    def pbThisEx(idxBattler,idxParty)
      party = pbParty(idxBattler)
      if opposes?(idxBattler)
        return _INTL("The opposing {1}",party[idxParty].name) if trainerBattle?
        return _INTL("The wild {1}",party[idxParty].name)
      end
      return _INTL("The ally {1}",party[idxParty].name) if !pbOwnedByPlayer?(idxBattler)
      return party[idxParty].name
    end
  
    def pbSetSeen(battler)
      return if !battler || !@internalBattle
      pbPlayer.pokedex.register(battler.displaySpecies,battler.displayGender,battler.displayForm)
    end
  
    def nextPickupUse
      @nextPickupUse += 1
      return @nextPickupUse
    end
  
    #=============================================================================
    # Weather and Field Effects
    #=============================================================================
    def defaultWeather=(value)
      @field.defaultWeather  = value
      @field.weather         = value
      @field.weatherDuration = -1
    end
  
    # Returns the effective weather (note that weather effects can be negated)
    def pbWeather
      eachBattler { |b| 
        return :None if b.hasActiveAbility?(:CLOUDNINE) && ![12,49].include?($fefieldeffect) ||
                        b.hasActiveAbility?(:AIRLOCK)
      }
      return @field.weather
    end
  
    # Used for causing weather by a move or by an ability.
    def pbStartWeather(user,newWeather,fixedDuration=false,showAnim=true,d=5)
      return if @field.weather==newWeather
      if pbCheckGlobalAbility(:CLOUDNINE) && [43,48].include?($fefieldeffect)
        pbDisplay(_INTL("Cloud Nine prevents the creation of weather."))
      elsif pbCheckGlobalAbility(:AIRLOCK) && [27,28,38,43].include?($fefieldeffect)
        pbDisplay(_INTL("Air Lock prevents the creation of weather."))
      end
      if [7,16].include?($fefieldeffect) && newWeather == :Hail
        pbDisplay(_INTL("The hail quickly melted away..."))
        return
      elsif $fefieldeffect == 12 && newWeather == :Hail
        newWeather = :Rain
      elsif $fefieldeffect == 38 && newWeather == :Sun
        pbDisplay(_INTL("The sun doesn't exist in this dimension..."))
        return
      elsif $fefieldeffect == 46 && newWeather == :Rain
        newWeather = :Hail
      end
      duration = (fixedDuration) ? d : -1
      if duration>0 && user && user.itemActive?
        duration = BattleHandlers.triggerWeatherExtenderItem(user.item,@field.weather,duration,user,self)
      end
      pbHideAbilitySplash(user) if user
      case newWeather
      when :Sun
        pbCommonAnimation("Sunny") if showAnim
        pbDisplay(_INTL("The sunlight turned harsh!"))
        duration = (duration * 1.5).ceil if [12,27,28,43,48,49].include?($fefieldeffect)
        if $fefieldeffect == 4
          changeField(25,"The sun lit up the crystal cavern!",1,false,true) # duration managed in terrain count to last as long as weather
        elsif $fefieldeffect == 34
          changeField(0,"The sun eclipsed the night sky!",1) # Duration managed elsewhere
        end
      when :Rain
        pbCommonAnimation("Rain") if showAnim
        pbDisplay(_INTL("It started to rain!"))
        duration = (duration * 1.5).ceil if [8,43].include?($fefieldeffect)
        duration = (duration / 1.5).floor if [12,16].include?($fefieldeffect)
        if $fefieldeffect == 7
          changeField(23,"The water extinguished the flame!",1) # Duration managed elsewhere
        elsif $fefieldeffect == 34
          changeField(0,"The rain clouds blocked the night sky!",1) # Duration managed elsewhere
        end
      when :Sandstorm
        pbCommonAnimation("Sandstorm") if showAnim
        pbDisplay(_INTL("A sandstorm brewed!"))
        duration = (duration * 1.5).ceil if [12,20,43,48,49].include?($fefieldeffect)
        if $fefieldeffect == 9
          changeField(0,"The sandstorm blocked out the rainbow!",1) # Duration managed elsewhere
        elsif $fefieldeffect == 34
          changeField(0,"The sandstorm blocked out the night sky!",1) # Duration managed elsewhere
        end
      when :Hail
        pbCommonAnimation("Hail") if showAnim
        pbDisplay(_INTL("It started to hail!"))
        duration = (duration * 1.5).ceil if [28,39,46].include?($fefieldeffect)
        duration = (duration / 1.5).floor if $fefieldeffect == 48
        if $fefieldeffect == 9
          changeField(0,"The hailstorm blocked out the rainbow!",1) # Duration managed elsewhere
        elsif $fefieldeffect == 34
          changeField(0,"The hailstorm blocked out the night sky!",1) # Duration managed elsewhere
        end
        eachBattler do |b|
          if b.hasActiveAbility?(:ICETUSKS)
            b.pbRaiseStatStageByAbility(:ATTACK,1,nil)
          end
        end
      when :HarshSun
        pbCommonAnimation("Sunny") if showAnim
        pbDisplay(_INTL("The sunlight turned extremely harsh!"))
        if $fefieldeffect == 4
          changeField(25,"The sun lit up the crystal cavern!",1,false,true) # Duration managed elsewhere
        elsif $fefieldeffect == 8
          changeField(0,"The harsh sun dried up the swamp!",1) # Duration managed elsewhere
        elsif [20,48].include?($fefieldeffect)
          changeField(12,"The harsh sun evaporated the water!",1,false,true) # Duration managed elsewhere
        elsif $fefieldeffect == 21
          changeField(48,"The harsh sun evaporated some of the water!",1,false,true) # Duration managed elsewhere
        elsif $fefieldeffect == 22
          changeField(21,"The harsh sun evaporated some of the water!",1,false,true) # Duration managed elsewhere
        elsif $fefieldeffect == 49
          changeField(12,"The harsh sun dried up the plants!",1,false,true) # Duration managed elsewhere
        end
      when :HeavyRain
        pbCommonAnimation("Rain") if showAnim
        pbDisplay(_INTL("A heavy rain began to fall!"))
        if [7,32].include?($fefieldeffect)
          changeField(23,"The water solidified the magma!",1) # Duration managed elsewhere
        elsif $fefieldeffect == 16
          changeField(27,"The water solidified the lava!",1) # Duration managed elsewhere
        elsif [20,48].include?($fefieldeffect)
          changeField(21,"The beach flooded!",1,false,true) # Duration managed elsewhere
        end
      when :StrongWinds
        pbCommonAnimation("Wind") if showAnim
        pbDisplay(_INTL("Mysterious strong winds are protecting Flying-type Pokémon!"))
        if [3,11].include?($fefieldeffect)
          changeField(0,"The air current blew away the mist!",1) # Duration handled elsewhere
        elsif $fefieldeffect == 20
          changeField(48,"The air current blew away the ash!",1,false,true) # Duration handled elsewhere
        end
      when :ShadowSky
        pbDisplay(_INTL("A shadow sky appeared!"))
      when :Fog
        pbDisplay(_INTL("The fog is deep..."))
      end
      if pbWeather == :Sun && newWeather == :Rain || pbWeather == :Rain && newWeather == :Sun
        changeField(9,"The weather combined to form a rainbow!",duration,false,true)
      end
      @field.weather = newWeather
      @field.weatherDuration = duration
      # Check for end of primordial weather, and weather-triggered form changes
      eachBattler { |b| b.pbCheckFormOnWeatherChange }
      pbEndPrimordialWeather
      pbCalculatePriority(true) if Settings::RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES
    end
  
    def pbEndPrimordialWeather
      return if @field.weatherDuration > 0 # Should be -1 if initiated by primal abilities
      oldWeather = @field.weather
      # End Primordial Sea, Desolate Land, Delta Stream
      case @field.weather
      when :HarshSun
        if !pbCheckGlobalAbility(:DESOLATELAND)
          @field.weather = :None
          @field.weatherDuration = 0
          pbDisplay(_INTL("The harsh sunlight faded!"))
          if $fefieldeffect == 25 && $febackup == 4 || $febackup == 8 || $fefieldeffect == 12 && 
             ($febackup == 20 || $febackup == 48 || $febackup == 49) || $fefieldeffect == 48 && 
             $febackup == 21 || $fefieldeffect == 21 && $febackup == 22
            changeField($febackup,"The terrain returned to normal.")
          end
        end
      when :HeavyRain
        if !pbCheckGlobalAbility(:PRIMORDIALSEA)
          @field.weather = :None
          @field.weatherDuration = 0
          pbDisplay(_INTL("The heavy rain has lifted!"))
          if $febackup == 7 || $febackup == 32 || $febackup == 16 || ($febackup == 20 || 
             $febackup == 48) && $fefieldeffect == 21
            changeField($febackup,"The terrain returned to normal.")
          end
        end
      when :StrongWinds
        if !pbCheckGlobalAbility(:DELTASTREAM)
          @field.weather = :None
          @field.weatherDuration = 0
          pbDisplay(_INTL("The mysterious air current has dissipated!"))
          if $febackup == 3 || $febackup == 11 || $febackup == 20 && $fefieldeffect == 48
            changeField($febackup,"The terrain returned to normal.")
          end
        end
      end
      if @field.weather!=oldWeather
        # Check for form changes caused by the weather changing
        eachBattler { |b| b.pbCheckFormOnWeatherChange }
        # Start up the default weather
        pbStartWeather(nil,@field.defaultWeather) if @field.defaultWeather != :None
      end
      pbCalculatePriority(true) if Settings::RECALCULATE_TURN_ORDER_AFTER_SPEED_CHANGES
    end
  
    def defaultTerrain=(value)
      @field.defaultTerrain  = value
      @field.terrain         = value
      @field.terrainDuration = -1
    end
    
    def changeField(field,message,duration=0,terrainExtender=false,preventReversion=false,overrideBackup=false)
      return if pbCheckGlobalAbility(:AMBIENTCONNECTION) || $fefieldeffect == field
      if $febackup == 0 # Changes to specification indefinitely and resets backup
        $fetempfield = field
        $fefieldeffect = $fetempfield
        overrideBackup = true
        @field.effects[PBEffects::FEDuration] = 0
      elsif $fefieldeffect == $febackup || preventReversion # Changes to specification for duration
        $fetempfield = field
        $fefieldeffect = $fetempfield
        duration = (duration*1.5).ceil if terrainExtender
        @field.effects[PBEffects::FEDuration] = duration
      else # Reverts field to backup indefinitely
        $fetempfield = $febackup
        $fefieldeffect = $fetempfield
        @field.effects[PBEffects::FEDuration] = 0
      end
      if overrideBackup
        $febackup = $fefieldeffect
      end
      $fecounter = 0
      changeFieldBG
      pbDisplay(_INTL(message)) if !message.nil?
      checkEffectsOnTerrainChange
      # Check for terrain seeds that boost stats in a terrain
      eachBattler { |b|
        b.pbCheckFormOnTerrainChange
        b.pbItemTerrainStatBoostCheck
      }
    end
    
    def rotateChessField
      return if $fefieldeffect != 5
      if $fecounter > 5 # Black
        $fecounter = 0
        fieldColor = "White"
      else # White
        $fecounter = 6
        fieldColor = "Black"
      end
      if singleBattle?
        $fecounter += pbRandom(3)
      else
        $fecounter += pbRandom(6)
      end
      case $fecounter%6
      when 0
        fieldPiece = "Pawn"
        eachBattler do |b|
          if b.hasActiveAbility?(:STANCECHANGE) && !b.effects[PBEffects::Transform]
            if b.form!=0
              b.pbChangeForm(0,_INTL("{1} changed to Shield Forme!",b.pbThis))
            end
            if b.hasAlteredStatStages?
              b.pbResetStatStages
              worked=true
            else
              worked=false
            end
            pbDisplay(_INTL("{1}'s stat changes were removed!",b.pbThis)) if worked
            b.pbRaiseStatStage(:SPEED,2,nil,true)
          end
        end
      when 1
        fieldPiece = "King"
        eachBattler do |b|
          if b.hasActiveAbility?(:STANCECHANGE) && !b.effects[PBEffects::Transform]
            if b.form!=0
              b.pbChangeForm(0,_INTL("{1} changed to Shield Forme!",b.pbThis))
            end
            if b.hasAlteredStatStages?
              b.pbResetStatStages
              worked=true
            else
              worked=false
            end
            pbDisplay(_INTL("{1}'s stat changes were removed!",b.pbThis)) if worked
            b.pbRaiseStatStage(:SPECIAL_DEFENSE,2,nil,true)
          end
        end
      when 2
        fieldPiece = "Queen"
        eachBattler do |b|
          if b.hasActiveAbility?(:STANCECHANGE) && !b.effects[PBEffects::Transform] &&
             b.pokemon.getNumForms>=1
            if b.form!=1
              b.pbChangeForm(1,_INTL("{1} changed to Blade Forme!",b.pbThis))
            end
            if b.hasAlteredStatStages?
              b.pbResetStatStages
              worked=true
            else
              worked=false
            end
            pbDisplay(_INTL("{1}'s stat changes were removed!",b.pbThis)) if worked
            b.pbRaiseStatStage(:SPECIAL_ATTACK,2,nil,true)
          end
        end
      when 3
        fieldPiece = "Knight"
        eachBattler do |b|
          if b.hasActiveAbility?(:STANCECHANGE) && !b.effects[PBEffects::Transform] &&
             b.pokemon.getNumForms>=1
            if b.form!=1
              b.pbChangeForm(1,_INTL("{1} changed to Blade Forme!",b.pbThis))
            end
            if b.hasAlteredStatStages?
              b.pbResetStatStages
              worked=true
            else
              worked=false
            end
            pbDisplay(_INTL("{1}'s stat changes were removed!",b.pbThis)) if worked
            b.pbRaiseStatStage(:EVASION,2,nil,true)
          end
        end
      when 4
        fieldPiece = "Bishop"
        eachBattler do |b|
          if b.hasActiveAbility?(:STANCECHANGE) && !b.effects[PBEffects::Transform] &&
             b.pokemon.getNumForms>=1
            if b.form!=1
              b.pbChangeForm(1,_INTL("{1} changed to Blade Forme!",b.pbThis))
            end
            if b.hasAlteredStatStages?
              b.pbResetStatStages
              worked=true
            else
              worked=false
            end
            pbDisplay(_INTL("{1}'s stat changes were removed!",b.pbThis)) if worked
            b.pbRaiseStatStage(:ACCURACY,2,nil,true)
          end
        end
      when 5
        fieldPiece = "Rook"
        eachBattler do |b|
          if b.hasActiveAbility?(:STANCECHANGE) && !b.effects[PBEffects::Transform]
            if b.form!=0
              b.pbChangeForm(0,_INTL("{1} changed to Shield Forme!",b.pbThis))
            end
            if b.hasAlteredStatStages?
              b.pbResetStatStages
              worked=true
            else
              worked=false
            end
            pbDisplay(_INTL("{1}'s stat changes were removed!",b.pbThis)) if worked
            b.pbRaiseStatStage(:DEFENSE,2,nil,true)
          end
        end
      end
      changeFieldBG
      pbDisplay(_INTL("It's now the {1}'s turn to move on the {2} side!",fieldPiece,fieldColor))
    end
    
    def changeCrystalBackground(newCount)
      return if $fecounter == newCount
      $fecounter = newCount
      newBG = nil
      case $fecounter
      when 0
        newBG = "CrystalCavern0"
      when 1
        newBG = "CrystalCavern1"
      when 2
        newBG = "CrystalCavern2"
      when 3
        newBG = "CrystalCavern3"
      when 4
        newBG = "CrystalCavern4"
      when 5
        newBG = "CrystalCavern5"
      when 6
        newBG = "CrystalCavern6"
      end
      pbSEPlay("Anim/PRSFX- Magic Coat")
      @backdrop = newBG
      @backdropBase = newBG
      @scene.pbCreateBackdropSprites
      pbDisplay(_INTL("The crystals changed color!"))
    end
    
    def changeFlowerGardenStage(stageChange,showMessages=true)
      originalCount = $fecounter
      $fecounter += stageChange
      $fecounter = [$fecounter,0].max
      $fecounter = [$fecounter,4].min
      return false if $fecounter == originalCount
      changeFieldBG
      return true if !showMessages
      stageChange = $fecounter - originalCount
      if stageChange > 0
        if stageChange == 1
          pbDisplay(_INTL("The garden grew by 1 stage!"))
        else
          pbDisplay(_INTL("The garden grew by {1} stages!",stageChange))
        end
      else
        if stageChange == -1
          pbDisplay(_INTL("The garden was cut by 1 stage!"))
        else
          pbDisplay(_INTL("The garden was cut by {1} stages!",stageChange*-1))
        end
      end
      return true
    end
    
    def changeFieldBG
      case $fefieldeffect
      when 1 # Electric Terrain
        pbCommonAnimation("ElectricTerrain")
      when 2 # Grassy Terrain
        pbCommonAnimation("GrassyTerrain")
      when 3 # Misty Terrain
        pbCommonAnimation("MistyTerrain")
      when 9 # Rainbow Field
        pbCommonAnimation("RainbowField")
      when 24 # Glitch Field
        pbCommonAnimation("GlitchField")
      when 37 # Psychic Terrain
        pbCommonAnimation("PsychicTerrain")
      else
        pbSEPlay("Anim/PRSFX- Magic Coat")
      end
      pbDisposeSprite(@scene.sprites,"battle_bg")
      pbDisposeSprite(@scene.sprites,"battle_bg2")
      pbDisposeSprite(@scene.sprites,"base_0")
      pbDisposeSprite(@scene.sprites,"base_1")
      pbDisposeSprite(@scene.sprites,"cmdBar_bg")
      if $fefieldeffect == $feinitial && ![5,25,33].include?($fefieldeffect) # Could be stage change
        newBG = $feinitialbg
      else
        case $fefieldeffect
        when 1
          newBG = "ElectricTerrain"
        when 2
          newBG = "GrassyTerrain"
        when 3
          newBG = "MistyTerrain"
        when 4
          newBG = "DarkCrystalCavern"
        when 5
          case $fecounter
          when 0
            newBG = "Chess0"
          when 1
            newBG = "Chess1"
          when 2
            newBG = "Chess2"
          when 3
            newBG = "Chess3"
          when 4
            newBG = "Chess4"
          when 5
            newBG = "Chess5"
          when 6
            newBG = "Chess6"
          when 7
            newBG = "Chess7"
          when 8
            newBG = "Chess8"
          when 9
            newBG = "Chess9"
          when 10
            newBG = "Chess10"
          when 11
            newBG = "Chess11"
          end
        when 6
          newBG = "Dancefloor"
        when 7
          newBG = "Volcanic2"
        when 8
          newBG = "Swamp"
        when 9
          newBG = "Rainbow"
        when 10
          newBG = "Corrosive"
        when 11
          newBG = "CorrosiveMist"
        when 12
          newBG = "Desert"
        when 13
          newBG = "IcyCave"
        when 14
          newBG = "Rocky"
        when 15
          newBG = "Forest"
        when 16
          newBG = "VolcanicTop"
        when 17
          newBG = "Factory"
        when 18
          newBG = "Shortcircuit"
        when 19
          newBG = "Wasteland"
        when 20
          newBG = "AshenBeach"
        when 21
          newBG = "WaterSurface"
        when 22
          newBG = "Underwater"
        when 23
          newBG = "Cave"
        when 24
          newBG = "Glitch"
        when 25
          case rand(7) # Random because activated from another field meaning there's no specificity
          when 0
            newBG = "CrystalCavern0"
          when 1
            $fecounter=1
            newBG = "CrystalCavern1"
          when 2
            $fecounter=2
            newBG = "CrystalCavern2"
          when 3
            $fecounter=3
            newBG = "CrystalCavern3"
          when 4
            $fecounter=4
            newBG = "CrystalCavern4"
          when 5
            $fecounter=5
            newBG = "CrystalCavern5"
          when 6
            $fecounter=6
            newBG = "CrystalCavern6"
          end
        when 26
          newBG = "MurkwaterSurface"
        when 27
          newBG = "Mountain"
        when 28
          newBG = "SnowyMountain"
        when 29
          newBG = "Holy"
        when 30
          newBG = "Mirror"
        when 31
          newBG = "FairyTale"
        when 32
          newBG = "DragonsDen"
        when 33
          case $fecounter
          when 0
            newBG = "FlowerGarden0"
          when 1
            newBG = "FlowerGarden1"
          when 2
            newBG = "FlowerGarden2"
          when 3
            newBG = "FlowerGarden3"
          when 4
            newBG = "FlowerGarden4"
          end
        when 34
          newBG = "Starlight"
        when 35
          newBG = "NewWorld"
        when 36
          newBG = "Inverse"
        when 37
          newBG = "PsychicTerrain"
        when 38
          newBG = "Dimensional"
        when 39
          newBG = "FrozenDimensional"
        when 40
          newBG = "Haunted"
        when 41
          newBG = "CorruptedCave"
        when 42
          newBG = "BewitchedWoods"
        when 43
          newBG = "Sky"
        when 44
          newBG = "Indoor1"
        when 45
          newBG = "BoxingRing"
        when 46
          newBG = "Subzero"
        when 47
          newBG = "Jungle"
        when 48
          newBG = "Beach"
        when 49
          newBG = "XericShrubland"
        else
          newBG = "Field"
        end
      end
      @backdrop = newBG
      @backdropBase = newBG
      @scene.pbCreateBackdropSprites
    end
  
    #=============================================================================
    # Messages and animations
    #=============================================================================
    def pbDisplay(msg,&block)
      @scene.pbDisplayMessage(msg,&block)
    end
  
    def pbDisplayBrief(msg)
      @scene.pbDisplayMessage(msg,true)
    end
  
    def pbDisplayPaused(msg,&block)
      @scene.pbDisplayPausedMessage(msg,&block)
    end
  
    def pbDisplayConfirm(msg)
      return @scene.pbDisplayConfirmMessage(msg)
    end
  
    def pbShowCommands(msg,commands,canCancel=true)
      @scene.pbShowCommands(msg,commands,canCancel)
    end
  
    def pbAnimation(move,user,targets,hitNum=0)
      @scene.pbAnimation(move,user,targets,hitNum) if @showAnims
    end
  
    def pbCommonAnimation(name,user=nil,targets=nil)
      @scene.pbCommonAnimation(name,user,targets) if @showAnims
    end
  
    def pbShowAbilitySplash(battler,delay=false,logTrigger=true,ability=nil)
      PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}") if logTrigger
      return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      @scene.pbShowAbilitySplash(battler,ability)
      if delay
        Graphics.frame_rate.times { @scene.pbUpdate }   # 1 second
      end
    end
  
    def pbHideAbilitySplash(battler)
      return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      @scene.pbHideAbilitySplash(battler)
    end
  
    def pbReplaceAbilitySplash(battler)
      return if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      @scene.pbReplaceAbilitySplash(battler)
    end
    
    #=============================================================================
    # Custom Miscellaneous Methods
    #=============================================================================
    def fieldType
      case $fefieldeffect
      when 1  then return :ELECTRIC
      when 2  then return :GRASS
      when 3  then return :FAIRY
      when 4  then return :DARK
      when 5  then return :PSYCHIC
      when 6  then return :NORMAL
      when 7  then return :FIRE
      when 8  then return :WATER
      when 9  then return generateRandomType
      when 10 then return :POISON
      when 11 then return :POISON
      when 12 then return :GROUND
      when 13 then return :ICE
      when 14 then return :ROCK
      when 15 then return :GRASS
      when 16 then return :FIRE
      when 17 then return :STEEL
      when 18 then return :ELECTRIC
      when 19 then return :POISON
      when 20 then return :GROUND
      when 21 then return :WATER
      when 22 then return :WATER
      when 23 then return :ROCK
      when 24 then return :QMARKS
      when 25 then return crystalType
      when 26 then return :POISON
      when 27 then return :ROCK
      when 28 then return :ICE
      when 29 then return :NORMAL
      when 30 then return :STEEL
      when 31 then return :FAIRY
      when 32 then return :DRAGON
      when 33 then return :GRASS
      when 34 then return :FAIRY
      when 35 then return generateRandomType
      when 36 then return :NORMAL
      when 37 then return :PSYCHIC
      when 38 then return :DARK
      when 39 then return :ICE
      when 40 then return :GHOST
      when 41 then return :POISON
      when 42 then return :FAIRY
      when 43 then return :FLYING
      when 44 then return :NORMAL
      when 45 then return :FIGHTING
      when 46 then return :ICE
      when 47 then return :BUG
      when 48 then return :GROUND
      when 49 then return :GROUND
      end
      return :NORMAL
    end
    
    def generateRandomType(includeQMARKS=false)
      max = (includeQMARKS) ? 19 : 18
      case rand(max)
      when 0  then return :NORMAL
      when 1  then return :FIGHTING
      when 2  then return :FLYING
      when 3  then return :POISON
      when 4  then return :GROUND
      when 5  then return :ROCK
      when 6  then return :BUG
      when 7  then return :GHOST
      when 8  then return :STEEL
      when 9  then return :FIRE
      when 10 then return :WATER
      when 11 then return :GRASS
      when 12 then return :ELECTRIC
      when 13 then return :PSYCHIC
      when 14 then return :ICE
      when 15 then return :DRAGON
      when 16 then return :DARK
      when 17 then return :FAIRY
      when 18 then return :QMARKS
      end
    end
    
    def crystalType
      case $fecounter
      when 0 then return :FIRE
      when 1 then return :WATER
      when 2 then return :GRASS
      when 3 then return :ELECTRIC
      when 4 then return :FAIRY
      when 5 then return :GHOST
      when 6 then return :PSYCHIC
      end
    end
    
    def generateRandomStat(includeAccEva=true) # Excludes HP
      max = (includeAccEva) ? 7 : 5
      case rand(max)
      when 0 then return :ATTACK
      when 1 then return :DEFENSE
      when 2 then return :SPECIAL_ATTACK
      when 3 then return :SPECIAL_DEFENSE
      when 4 then return :SPEED
      when 5 then return :ACCURACY
      when 6 then return :EVASION
      end
    end
    
    def trappingTargetAbility?(switcher,bearer)
      if bearer.hasActiveAbility?(:ARENATRAP) && (!switcher.airborne? || [5,23,44,45].include?($fefieldeffect)) &&
         ![21,38,43].include?($fefieldeffect)
        return true
      end
      if bearer.hasActiveAbility?(:MAGNETPULL) && (switcher.pbHasType?(:STEEL) || 
         [1,18].include?($fefieldeffect) && switcher.pbHasType?(:ELECTRIC) || [4,25].include?($fefieldeffect) &&
         switcher.pbHasType?(:ROCK)) && ![35,38,39].include?($fefieldeffect)
        return true
      end
      if bearer.hasActiveAbility?(:SHADOWTAG) && ![:Sun,:HarshSun].include?(pbWeather) &&
         ![9,29].include?($fefieldeffect)
        return true
      end
      if bearer.hasActiveAbility?(:ALPHABETIZATION) && (bearer.checkAlphabetizationForm(2) ||
         bearer.checkAlphabetizationForm(23))
        return true
      end
      if bearer.hasActiveAbility?(:FLYTRAP) && switcher.pbHasType?(:BUG) && (bearer.near?(switcher) ||
         $fefieldeffect == 33 && $fecounter >= 3) && $fefieldeffect != 22
        return true
      end
      return false
    end
    
    def dampBattler?
      return pbCheckGlobalAbility(:DAMP) && ![7,12,49] || [3,8,22].include?($fefieldeffect)
    end
    
    # Removes certain effects that wouldn't be possible in the new field that were initiated in the old one
    def checkEffectsOnTerrainChange
      if [7,16].include?($fefieldeffect) && @field.weather == :Hail
        pbDisplay(_INTL("The hail quickly melted away..."))
        @field.weather = :None
        @field.weatherDuration = 0
      elsif $fefieldeffect == 12 && @field.weather == :Hail
        startWeather(nil,:Rain,false,true,@field.weatherDuration)
      elsif $fefieldeffect == 38 && @field.weather == :Sun
        pbDisplay(_INTL("The sun doesn't exist in this dimension..."))
        @field.weather = :None
        @field.weatherDuration = 0
      elsif $fefieldeffect == 46 && @field.weather == :Rain
        startWeather(nil,:Hail,false,true,@field.weatherDuration)
      end
      @field.effects[PBEffects::StrikeValue] = 0
      eachBattler do |b|
        b.effects[PBEffects::HolyAbilities] = []
        b.effects[PBEffects::WasteAnger] = 0
        b.effects[PBEffects::FairyTaleRoles] = []
        b.effects[PBEffects::HauntedScared] = -1
        b.effects[PBEffects::BewitchedMark] = false
        b.effects[PBEffects::Persistence] = false
        b.effects[PBEffects::StrikeValue] = 0
      end
      if $fefieldeffect == 30
        eachBattler do |b|
          b.effects[PBEffects::SpyGear] = 0
        end
      end
      for side in 0...2
        if @sides[side].effects[PBEffects::Spikes] > 0
          if [21,26].include?($fefieldeffect)
            @sides[side].effects[PBEffects::Spikes] = 0
            pbDisplay(_INTL("The spikes affecting {1} vanished to the seafloor...",@battlers[side].pbTeam))
          elsif $fefieldeffect == 43
            @sides[side].effects[PBEffects::Spikes] = 0
            pbDisplay(_INTL("The spikes affecting {1} vanished to the ground below...",@battlers[side].pbTeam))
          end
        end
        if @sides[side].effects[PBEffects::ToxicSpikes] > 0
          if [21,26].include?($fefieldeffect)
            @sides[side].effects[PBEffects::ToxicSpikes] = 0
            pbDisplay(_INTL("The toxic spikes affecting {1} vanished to the seafloor...",@battlers[side].pbTeam))
          elsif $fefieldeffect == 43
            @sides[side].effects[PBEffects::ToxicSpikes] = 0
            pbDisplay(_INTL("The toxic spikes affecting {1} vanished to the ground below...",@battlers[side].pbTeam))
          end
        end
        if @sides[side].effects[PBEffects::StickyWeb] && $fefieldeffect == 43
          @sides[side].effects[PBEffects::StickyWeb] = false
          pbDisplay(_INTL("The sticky web affecting {1} vanished to the ground below...",@battlers[side].pbTeam))
        end
      end
      if [3,22,43].include?($fefieldeffect) && @field.effects[PBEffects::NeutralizingGas]
        @field.effects[PBEffects::NeutralizingGas] = false
        pbDisplay(_INTL("The neutralizing gas dissipated!"))
      end
    end
    
    def generateRandomField(includeCurrent=true)
      if includeCurrent
        return rand(50)
      else
        return ($fefieldeffect + 1 + rand(49)) % 50
      end
    end
  end
  