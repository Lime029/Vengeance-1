#===============================================================================
# Entering/exiting cave animations
#===============================================================================
def pbCaveEntranceEx(exiting)
    # Create bitmap
    sprite = BitmapSprite.new(Graphics.width,Graphics.height)
    sprite.z = 100000
    # Define values used for the animation
    totalFrames = (Graphics.frame_rate*0.4).floor
    increment = (255.0/totalFrames).ceil
    totalBands = 15
    bandheight = ((Graphics.height/2.0)-10)/totalBands
    bandwidth  = ((Graphics.width/2.0)-12)/totalBands
    # Create initial array of band colors (black if exiting, white if entering)
    grays = Array.new(totalBands) { |i| (exiting) ? 0 : 255 }
    # Animate bands changing color
    totalFrames.times do |j|
      x = 0
      y = 0
      # Calculate color of each band
      for k in 0...totalBands
        next if k>=totalBands*j/totalFrames
        inc = increment
        inc *= -1 if exiting
        grays[k] -= inc
        grays[k] = 0 if grays[k]<0
      end
      # Draw gray rectangles
      rectwidth  = Graphics.width
      rectheight = Graphics.height
      for i in 0...totalBands
        currentGray = grays[i]
        sprite.bitmap.fill_rect(Rect.new(x,y,rectwidth,rectheight),
           Color.new(currentGray,currentGray,currentGray))
        x += bandwidth
        y += bandheight
        rectwidth  -= bandwidth*2
        rectheight -= bandheight*2
      end
      Graphics.update
      Input.update
    end
    # Set the tone at end of band animation
    if exiting
      pbToneChangeAll(Tone.new(255,255,255),0)
    else
      pbToneChangeAll(Tone.new(-255,-255,-255),0)
    end
    # Animate fade to white (if exiting) or black (if entering)
    for j in 0...totalFrames
      if exiting
        sprite.color = Color.new(255,255,255,j*increment)
      else
        sprite.color = Color.new(0,0,0,j*increment)
      end
      Graphics.update
      Input.update
    end
    # Set the tone at end of fading animation
    pbToneChangeAll(Tone.new(0,0,0),8)
    # Pause briefly
    (Graphics.frame_rate/10).times do
      Graphics.update
      Input.update
    end
    sprite.dispose
  end
  
  def pbCaveEntrance
    pbSetEscapePoint
    pbCaveEntranceEx(false)
  end
  
  def pbCaveExit
    pbEraseEscapePoint
    pbCaveEntranceEx(true)
  end
  
  
  
  #===============================================================================
  # Blacking out animation
  #===============================================================================
  def pbStartOver(gameover=false)
    if pbInBugContest?
      pbBugContestStartOver
      return
    end
    $Trainer.heal_party
    if $PokemonGlobal.pokecenterMapId && $PokemonGlobal.pokecenterMapId>=0
      if gameover
        if $game_switches[104] # Celebi Rescue
          if $PokemonGlobal.celebiRescueMapId && $PokemonGlobal.celebiRescueMapId>=0
            pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You mysteriously appear back at a recently visited location."))
          else
            pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You mysteriously appear back at a recently visited healing location."))
          end
          $game_variables[36] += 1
        else
          pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, you scurry back to a recently visited healing location."))
        end
  #      pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, you scurry back to a Pok??mon Center."))
      else
        if $game_switches[104] # Celebi Rescue
          if $PokemonGlobal.celebiRescueMapId && $PokemonGlobal.celebiRescueMapId>=0
            pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You mysteriously appear back at a recently visited location."))
          else
            pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You mysteriously appear back at a recently visited healing location."))
          end
          $game_variables[36] += 1
        else
          pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You scurry back to a recently visited healing location, protecting your exhausted Pok??mon from any further harm..."))
        end
  #      pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You scurry back to a Pok??mon Center, protecting your exhausted Pok??mon from any further harm..."))
      end
      pbCancelVehicles
      pbRemoveDependencies
      if $game_switches[104] && $PokemonGlobal.celebiRescueMapId && $PokemonGlobal.celebiRescueMapId>=0
        $game_temp.player_new_map_id    = $PokemonGlobal.celebiRescueMapId
        $game_temp.player_new_x         = $PokemonGlobal.celebiRescueX
        $game_temp.player_new_y         = $PokemonGlobal.celebiRescueY
        $game_temp.player_new_direction = $PokemonGlobal.celebiRescueDirection
        $Trainer.heal_party
      else
        $game_temp.player_new_map_id    = $PokemonGlobal.pokecenterMapId
        $game_temp.player_new_x         = $PokemonGlobal.pokecenterX
        $game_temp.player_new_y         = $PokemonGlobal.pokecenterY
        $game_temp.player_new_direction = $PokemonGlobal.pokecenterDirection
        $game_switches[Settings::STARTING_OVER_SWITCH] = true
      end
      $scene.transfer_player if $scene.is_a?(Scene_Map)
      $game_map.refresh
    else
      homedata = GameData::Metadata.get.home
      if homedata && !pbRgssExists?(sprintf("Data/Map%03d.rxdata",homedata[0]))
        if $DEBUG
          pbMessage(_ISPRINTF("Can't find the map 'Map{1:03d}' in the Data folder. The game will resume at the player's position.",homedata[0]))
        end
        $Trainer.heal_party
        return
      end
      if gameover
        if $game_switches[104] # Celebi Rescue
          pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You mysteriously appear back at home."))
          $game_variables[36] += 1
        else
          pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, you scurry back home."))
        end
  #      pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]After the unfortunate defeat, you scurry back home."))
      else
        if $game_switches[104] # Celebi Rescue
          pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You mysteriously appear back at home."))
          $game_variables[36] += 1
        else
          pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You scurry back home, protecting your exhausted Pok??mon from any further harm..."))
        end
  #      pbMessage(_INTL("\\w[]\\wm\\c[8]\\l[3]You scurry back home, protecting your exhausted Pok??mon from any further harm..."))
      end
      if homedata
        pbCancelVehicles
        pbRemoveDependencies
        if $game_switches[104] && $PokemonGlobal.celebiRescueMapId && $PokemonGlobal.celebiRescueMapId>=0
          $game_temp.player_new_map_id    = $PokemonGlobal.celebiRescueMapId
          $game_temp.player_new_x         = $PokemonGlobal.celebiRescueX
          $game_temp.player_new_y         = $PokemonGlobal.celebiRescueY
          $game_temp.player_new_direction = $PokemonGlobal.celebiRescueDirection
          $Trainer.heal_party
        else
          $game_switches[Settings::STARTING_OVER_SWITCH] = true
          $game_temp.player_new_map_id    = homedata[0]
          $game_temp.player_new_x         = homedata[1]
          $game_temp.player_new_y         = homedata[2]
          $game_temp.player_new_direction = homedata[3]
        end
        $scene.transfer_player if $scene.is_a?(Scene_Map)
        $game_map.refresh
      else
        $Trainer.heal_party
      end
    end
    pbEraseEscapePoint
  end
  