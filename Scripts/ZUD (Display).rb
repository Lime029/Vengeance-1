class PokemonDataBox < SpriteWrapper
    #-----------------------------------------------------------------------------
    # Updates databoxes in battle.
    #-----------------------------------------------------------------------------
    def refresh
      self.bitmap.clear
      return if !@battler.pokemon
      textPos = []
      imagePos = []
      self.bitmap.blt(0,0,@databoxBitmap.bitmap,Rect.new(0,0,@databoxBitmap.width,@databoxBitmap.height))
      nameWidth = self.bitmap.text_size(@battler.name).width
      nameOffset = 0
      nameOffset = nameWidth-116 if nameWidth>116
      textPos.push([@battler.name,@spriteBaseX+8-nameOffset,0,false,NAME_BASE_COLOR,NAME_SHADOW_COLOR])
      case @battler.displayGender
      when 0   # Male
        textPos.push([_INTL("♂"),@spriteBaseX+126,0,false,MALE_BASE_COLOR,MALE_SHADOW_COLOR])
      when 1   # Female
        textPos.push([_INTL("♀"),@spriteBaseX+126,0,false,FEMALE_BASE_COLOR,FEMALE_SHADOW_COLOR])
      end
      imagePos.push(["Graphics/Pictures/Battle/overlay_lv",@spriteBaseX+140,16])
      pbDrawNumber(@battler.level,self.bitmap,@spriteBaseX+162,16)
      pbDrawTextPositions(self.bitmap,textPos)
      if @battler.shiny?
        shinyX = (@battler.opposes?(0)) ? 206 : -6
        imagePos.push(["Graphics/Pictures/shiny",@spriteBaseX+shinyX,36])
      end
      specialX = (@battler.opposes?) ? 208 : -28
      if @battler.mega?
        imagePos.push(["Graphics/Pictures/Battle/icon_mega",@spriteBaseX+8,34])
      elsif @battler.primal?
        if @battler.isSpecies?(:KYOGRE)
          imagePos.push(["Graphics/Pictures/Battle/icon_primal_Kyogre",@spriteBaseX+specialX,4])
        elsif @battler.isSpecies?(:GROUDON)
          imagePos.push(["Graphics/Pictures/Battle/icon_primal_Groudon",@spriteBaseX+specialX,4])
        end
      elsif @battler.ultra?
        imagePos.push(["Graphics/Pictures/Battle/icon_ultra",@spriteBaseX+specialX+2,4])
      end
      if @battler.owned? && @battler.opposes?(0)
        imagePos.push(["Graphics/Pictures/Battle/icon_own",@spriteBaseX+8,36])
      end
      if @battler.status != :NONE
        s = GameData::Status.get(@battler.status).id_number
        if s == :POISON && @battler.statusCount > 0
          s = GameData::Status::DATA.keys.length / 2
        end
        imagePos.push(["Graphics/Pictures/Battle/icon_statuses",@spriteBaseX+24,36,
           0,(s-1)*STATUS_ICON_HEIGHT,-1,STATUS_ICON_HEIGHT])
      end
      pbDrawImagePositions(self.bitmap,imagePos)
      refreshHP
      refreshExp
    end
  end
  
  #===============================================================================
  # Adds ZUD buttons to the fight menu.
  #===============================================================================
  class FightMenuDisplay < BattleMenuBase
    def dispose
      super
      @buttonBitmap.dispose  if @buttonBitmap
      @typeBitmap.dispose    if @typeBitmap
      @battleButtonBitmap.each { |k,bmp| bmp.dispose if bmp}
      @shiftBitmap.dispose   if @shiftBitmap
    end
    
    #-----------------------------------------------------------------------------
    # Allows for shortened move names to display.
    #-----------------------------------------------------------------------------
    def refreshButtonNames
      moves = (@battler) ? @battler.moves : []
      if !USE_GRAPHICS
        commands = []
        for i in 0...[4, moves.length].max
          commands.push((moves[i]) ? moves[i].short_name : "-")
        end
        @cmdWindow.commands = commands
        return
      end
      @overlay.bitmap.clear
      textPos = []
      @buttons.each_with_index do |button,i|
        next if !@visibility["button_#{i}"]
        x = button.x-self.x+button.src_rect.width/2
        y = button.y-self.y+2
        moveNameBase = TEXT_BASE_COLOR
        if moves[i].type
          moveNameBase = button.bitmap.get_pixel(10,button.src_rect.y+34)
        end
        textPos.push([moves[i].short_name,x,y,2,moveNameBase,TEXT_SHADOW_COLOR])
      end
      pbDrawTextPositions(@overlay.bitmap,textPos)
    end  
    
    #-----------------------------------------------------------------------------
    # Displays appropriate button for battle mechanics.
    #-----------------------------------------------------------------------------
    def refreshBattleButton
      return if !USE_GRAPHICS
      if @chosen_button==NoButton
        @visibility["battleButton"] = false
        return
      end
      @battleButton.bitmap = @battleButtonBitmap[@chosen_button].bitmap
      @battleButton.x      = self.x+120
      @battleButton.y      = self.y-@battleButtonBitmap[@chosen_button].height/2
      @battleButton.src_rect.height = @battleButtonBitmap[@chosen_button].height/2
      @battleButton.src_rect.y    = (@mode - 1) * @battleButtonBitmap[@chosen_button].height / 2
      @battleButton.x             = self.x + ((@shiftMode > 0) ? 204 : 120)
      @battleButton.z             = self.z - 1
      @visibility["battleButton"] = (@mode > 0)
    end
    
    def chosen_button=(value)
      oldValue = @chosen_button
      @chosen_button = value
      refresh if @chosen_button!=oldValue
    end
    
    def refresh
      return if !@battler
      refreshSelection
      refreshBattleButton
      refreshShiftButton
      refreshButtonNames
    end
  end
  
  def pbPlayZUDButton
    if FileTest.audio_exist?("Audio/SE/GUI sel cancel")
      pbSEPlay("GUI ZUD Button",80)
    else
      pbPlayDecisionSE
    end
  end