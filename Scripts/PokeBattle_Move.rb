class PokeBattle_Move
    attr_reader   :battle
    attr_reader   :realMove
    attr_accessor :id
    attr_reader   :name
    attr_reader   :function
    attr_reader   :baseDamage
    attr_reader   :type
    attr_reader   :category
    attr_reader   :accuracy
    attr_accessor :pp
    attr_writer   :total_pp
    attr_reader   :addlEffect
    attr_reader   :target
    attr_reader   :priority
    attr_reader   :flags
    attr_accessor :powerBoost
    attr_accessor :snatched
    attr_accessor :types
    attr_accessor :calcTypes
    attr_accessor :moveBlacklist # Used for Copycat and such
  
    def to_int; return @id; end
  
    #=============================================================================
    # Creating a move
    #=============================================================================
    def initialize(battle, move)
      @battle     = battle
      @realMove   = move
      @id         = move.id
      @name       = move.name   # Get the move's name
      # Get data on the move
      @function   = move.function_code
      @baseDamage = move.base_damage
      @type       = move.type
      @category   = move.category
      @accuracy   = move.accuracy
      @pp         = move.pp   # Can be changed with Mimic/Transform
      @addlEffect = move.effect_chance
      @target     = move.target
      @priority   = move.priority
      @flags      = move.flags
      @powerBoost = 1   # For Aerilate, Pixilate, Refrigerate, Galvanize
      @snatched   = false
      @types      = [@type]
      @calcTypes  = nil
      @moveBlacklist=[]
    end
  
    # This is the code actually used to generate a PokeBattle_Move object. The
    # object generated is a subclass of this one which depends on the move's
    # function code (found in the script section PokeBattle_MoveEffect).
    def PokeBattle_Move.from_pokemon_move(battle, move)
      validate move => Pokemon::Move
      moveFunction = move.function_code || "000"
      className = sprintf("PokeBattle_Move_%s", moveFunction)
      if Object.const_defined?(className)
        return Object.const_get(className).new(battle, move)
      end
      return PokeBattle_UnimplementedMove.new(battle, move)
    end
  
    #=============================================================================
    # About the move
    #=============================================================================
    def pbTarget(_user); return GameData::Target.get(@target); end
  
    def total_pp
      return @total_pp if @total_pp && @total_pp>0   # Usually undefined
      return @realMove.total_pp if @realMove
      return 0
    end
  
    # NOTE: This method is only ever called while using a move (and also by the
    #       AI), so using @calcType here is acceptable.
    def physicalMove?(thisType=nil)
      return (@category==0) if Settings::MOVE_CATEGORY_PER_MOVE && $fefieldeffect != 24
      #thisType ||= @calcTypes[0]
      thisType ||= @type
      return true if !thisType
      return GameData::Type.get(thisType).physical?
    end
  
    # NOTE: This method is only ever called while using a move (and also by the
    #       AI), so using @calcType here is acceptable.
    def specialMove?(thisType=nil)
      return (@category==1) if Settings::MOVE_CATEGORY_PER_MOVE && $fefieldeffect != 24
      #thisType ||= @calcTypes[0]
      thisType ||= @type
      return false if !thisType
      return GameData::Type.get(thisType).special?
    end
  
    def damagingMove?; return @category!=2; end
    def statusMove?;   return @category==2; end
  
    def usableWhenAsleep?;       return false; end
    def unusableInGravity?;      return false; end
    def healingMove?;            return false; end
    def recoilMove?;             return false; end
    def flinchingMove?;          return false; end
    def callsAnotherMove?;       return false; end
    # Whether the move can/will hit more than once in the same turn (including
    # Beat Up which may instead hit just once). Not the same as pbNumHits>1.
    def multiHitMove?;           return false; end
    def chargingTurnMove?;       return false; end
    def successCheckPerHit?;     return false; end
    def hitsFlyingTargets?;      return false; end
    def hitsDiggingTargets?;     return false; end
    def hitsDivingTargets?;      return false; end
    def ignoresReflect?(user) # For Brick Break
      return user.hasActiveAbility?([:INFILTRATOR,:GLEAMEYES]) || user.hasActiveAbility?(:UNSEENFIST) && 
             [34,38].include?($fefieldeffect)
    end
    def cannotRedirect?;         return false; end   # For Future Sight/Doom Desire
    def worksWithNoTargets?;     return false; end   # For Explosion
    def damageReducedByBurn?;    return true;  end   # For Facade
    def triggersHyperMode?;      return false; end
  
    def contactMove?;       return @flags[/a/]; end
    def canProtectAgainst?(user)
      return @flags[/b/] && !(user.hasActiveAbility?(:UNSEENFIST) && contactMove? &&
             $fefieldeffect != 30 || user.hasActiveAbility?(:GLEAMEYES))
    end
    def canMagicCoat?;      return @flags[/c/]; end
    def canSnatch?;         return @flags[/d/]; end
    def canMirrorMove?;     return @flags[/e/]; end
    def canKingsRock?;      return @flags[/f/]; end
    def thawsUser?;         return @flags[/g/]; end
    def highCriticalRate?;  return @flags[/h/]; end
    def bitingMove?;        return @flags[/i/]; end
    def punchingMove?;      return @flags[/j/]; end
    def soundMove?(user)
      return true if @id == :THUNDER && $fefieldeffect == 43
      return true if user && user.hasActiveAbility?(:MARACAMOVEMENT) && danceMove? &&
                     $fefieldeffect != 22
      return @flags[/k/]
    end
    def powderMove?;        return @flags[/l/]; end
    def pulseMove?;         return @flags[/m/]; end
    def bombMove?;          return @flags[/n/]; end
    def danceMove?;         return @flags[/o/]; end
    def slashingMove?;      return @flags[/p/]; end
    def kickingMove?;       return @flags[/q/]; end
    def beamMove?;          return @flags[/r/]; end
    def windMove?;          return @flags[/s/]; end
    def piercingMove?;      return @flags[/t/]; end
    # 'z' used for Z-Moves
    
    def focusMove? # Used in Ashen Beach
      return [:STRENGTH,:AURASPHERE,:PSYCHIC,:STOREDPOWER,:ZENHEADBUTT,:FOCUSBLAST,
             :FOCUSPUNCH,:KARATECHOP,:REVERSAL,:FUTURESIGHT,:ENERGYBALL,:INFINITEFORCE,
             :CLANGOROUSSOULBLAZE,:OCEANICOPERETTA].include?(@id) || isHiddenPower?
    end
  
    def crystalRefractMove? # Used in Dark Crystal Cavern and Crystal Cavern
      return beamMove? || [:THUNDERSHOCK,:THUNDERBOLT,:CONFUSERAY,:FIREBLAST,:FLASH,
             :TRIATTACK,:SHADOWBALL,:LUSTERPURGE,:BLASTBURN,:HYDROCANNON,:WEATHERBALL,
             :WATERPULSE,:POWERGEM,:ENERGYBALL,:MIRRORSHOT,:JUDGMENT,:SPACIALREND,
             :PSYSHOCK,:VENOSHOCK,:ELECTROBALL,:HEX,:WATERPLEDGE,:FIREPLEDGE,:GRASSPLEDGE,
             :NIGHTDAZE,:PSYSTRIKE,:FUSIONFLARE,:MYSTICALFIRE,:COREENFORCER,:PHOTONGEYSER,
             :EXPANDINGFORCE,:DRAGONENERGY,:REACTIVEPOISON,:ABSORBVITALITY,:TURBODRIVE,
             :ETERNALFLAME,:INFINITEFORCE,:CHAINLIGHTNING,:FIRESPIN].include?(@id) ||
             isHiddenPower?
    end
    
    def chessMove?(user) # Used in Chess Board
      return [:STRENGTH,:ANCIENTPOWER,:PSYCHIC,:PURSUIT,:LASTRESORT,:FORCEPALM,:BULLDOZE,
             :ACCELEROCK,:FALSESURRENDER,:POLTERGEIST,:ROYALBLADES].include?(@id) ||
             damagingMove? && (@type == :NORMAL && ($fecounter < 6 || user && user.hasActiveAbility?(:INFILTRATOR)) || 
             @type == :DARK && ($fecounter >= 6 || user && user.hasActiveAbility?(:INFILTRATOR)))
    end
    
    def rageMove? # Used in Frozen Dimensional Field
      return [:THRASH,:RAGE,:TECTONICRAGE,:OUTRAGE,:FRUSTRATION,:REVENGE,:FRENZYPLANT,
             :PSYCHOBOOST,:PSYCHOCUT,:PAYBACK,:PLAYROUGH,:FURYATTACK,:HYPERSPACEFURY,
             :ALLOUTPUMMELING,:STOMPINGTANTRUM,:BURNINGJEALOUSY,:LASHOUT,:BITTERMALICE].include?(@id)
    end
    
    def witchMove? # Used in Bewitched Woods
      return [:MYSTICALFIRE,:MAGICALLEAF,:HYPNOSIS,:CONFUSERAY,:KINESIS,:TRANSFORM,
             :CURSE,:SPITE,:PERISHSONG,:RAINDANCE,:WILLOWISP,:MAGICCOAT,:SKILLSWAP,
             :IMPRISON,:COSMICPOWER,:SIGNALBEAM,:EXTRASENSORY,:DRAGONDANCE,:DOOMDESIRE,
             :GRAVITY,:PSYCHOSHIFT,:HEALBLOCK,:POWERTRICK,:POWERSWAP,:GUARDSWAP,:LUCKYCHANT,
             :WORRYSEED,:TELEKINESIS,:HEARTSWAP,:MAGNETRISE,:AURASPHERE,:POWERGEM,
             :TRICKROOM,:WONDERROOM,:MAGICROOM,:DARKVOID,:SHADOWFORCE,:PHANTOMFORCE,
             :GUARDSPLIT,:POWERSPLIT,:EERIEIMPULSE,:STRENGTHSAP,:SPEEDSWAP,:SOULSTEALING7STARSTRIKE,
             :SPECTRALTHIEF,:SPIRITBREAK,:POLTERGEIST,:SOULTHIEF,:INFERNALPARADE].include?(@id)
    end
    # Causes perfect accuracy (param=1) and double damage (param=2).
    def tramplesMinimize?(_param=1); return false; end
    def nonLethal?(_user,_target); return false; end   # For False Swipe
  
    def ignoresSubstitute?(user)   # user is the Pokémon using this move
      if Settings::MECHANICS_GENERATION >= 6
        return true if soundMove?(user) && $fefieldeffect != 14
        return true if user && (user.hasActiveAbility?(:INFILTRATOR) || user.hasActiveAbility?(:UNSEENFIST) && 
                       [34,38].include?($fefieldeffect))
      end
      return false
    end
    
    def numTargets(user) # Returns -1 if targeting a side of the field
      target_data = pbTarget(user)
      num_targets = 0
      case target_data.id
      when :None # Counter, Mirror Coat, etc. will eventually have 1 target
        num_targets += 1
      when :User
        num_targets += 1
      when :NearAlly
        num_targets += 1
      when :UserOrNearAlly
        num_targets += 1
      when :UserAndAllies
        @battle.eachSameSideBattler(user) { |_b| num_targets += 1 }
      when :NearFoe
        num_targets += 1
      when :RandomNearFoe
        num_targets += 1
      when :AllNearFoes
        @battle.eachOtherSideBattler(user) { |b| num_targets += 1 if b.near?(user) }
      when :Foe
        num_targets += 1
      when :AllFoes
        @battle.eachOtherSideBattler(user) { |_b| num_targets += 1 }
      when :NearOther
        num_targets += 1
      when :AllNearOthers
        @battle.eachBattler { |b| num_targets += 1 if b.near?(user) }
      when :Other
        num_targets += 1
      when :AllBattlers
        @battle.eachBattler { |_b| num_targets += 1 }
      when :UserSide
        num_targets = -1
      when :FoeSide
        num_targets = -1
      when :BothSides
        num_targets = -1
      end
      return num_targets
    end
    
    def isHiddenPower?
      return [:HIDDENPOWER,:HIDDENPOWERFAI,:HIDDENPOWERFIR,:HIDDENPOWERWAT,:HIDDENPOWERGRA,
             :HIDDENPOWERELE,:HIDDENPOWERICE,:HIDDENPOWERFIG,:HIDDENPOWERPOI,:HIDDENPOWERGRO,
             :HIDDENPOWERROC,:HIDDENPOWERBUG,:HIDDENPOWERFLY,:HIDDENPOWERPSY,:HIDDENPOWERGHO,
             :HIDDENPOWERDRA,:HIDDENPOWERDAR,:HIDDENPOWERSTE].include?(@id)
    end
  end
  