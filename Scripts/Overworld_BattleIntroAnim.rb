#===============================================================================
# Battle intro animation
#===============================================================================
def pbSceneStandby
    $scene.disposeSpritesets if $scene && $scene.is_a?(Scene_Map)
    RPG::Cache.clear
    Graphics.frame_reset
    yield
    $scene.createSpritesets if $scene && $scene.is_a?(Scene_Map)
  end
  
  def pbBattleAnimation(bgm=nil,battletype=0,foe=nil)
    $game_temp.in_battle = true
    viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z = 99999
    # Set up audio
    playingBGS = nil
    playingBGM = nil
    if $game_system && $game_system.is_a?(Game_System)
      playingBGS = $game_system.getPlayingBGS
      playingBGM = $game_system.getPlayingBGM
      $game_system.bgm_pause
      $game_system.bgs_pause
    end
    pbMEFade(0.25)
    pbWait(Graphics.frame_rate/4)
    pbMEStop
    # Play battle music
    bgm = pbGetWildBattleBGM([]) if !bgm
    pbBGMPlay(bgm)
    # Take screenshot of game, for use in some animations
    $game_temp.background_bitmap.dispose if $game_temp.background_bitmap
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    # Check for custom battle intro animations
    handled = pbBattleAnimationOverride(viewport,battletype,foe)
    # Default battle intro animation
    if !handled
      # Determine which animation is played
      location = 0   # 0=outside, 1=inside, 2=cave, 3=water
      if $PokemonGlobal.surfing || $PokemonGlobal.diving
        location = 3
      elsif $PokemonTemp.encounterType &&
         GameData::EncounterType.get($PokemonTemp.encounterType).type == :fishing
        location = 3
      elsif $PokemonEncounters.has_cave_encounters?
        location = 2
      elsif !GameData::MapMetadata.exists?($game_map.map_id) ||
            !GameData::MapMetadata.get($game_map.map_id).outdoor_map
        location = 1
      end
      anim = ""
      if PBDayNight.isDay?
        case battletype
        when 0, 2   # Wild, double wild
          anim = ["SnakeSquares","DiagonalBubbleTL","DiagonalBubbleBR","RisingSplash"][location]
        when 1      # Trainer
          anim = ["TwoBallPass","ThreeBallDown","BallDown","WavyThreeBallUp"][location]
        when 3      # Double trainer
          anim = "FourBallBurst"
        end
      else
        case battletype
        when 0, 2   # Wild, double wild
          anim = ["SnakeSquares","DiagonalBubbleBR","DiagonalBubbleBR","RisingSplash"][location]
        when 1      # Trainer
          anim = ["SpinBallSplit","BallDown","BallDown","WavySpinBall"][location]
        when 3      # Double trainer
          anim = "FourBallBurst"
        end
      end
      # Initial screen flashing
      if location==2 || PBDayNight.isNight?
        viewport.color = Color.new(0,0,0)         # Fade to black a few times
      else
        viewport.color = Color.new(255,255,255)   # Fade to white a few times
      end
      halfFlashTime = Graphics.frame_rate*2/10   # 0.2 seconds, 8 frames
      alphaDiff = (255.0/halfFlashTime).ceil
      2.times do
        viewport.color.alpha = 0
        for i in 0...halfFlashTime*2
          if i<halfFlashTime; viewport.color.alpha += alphaDiff
          else;               viewport.color.alpha -= alphaDiff
          end
          Graphics.update
          pbUpdateSceneMap
        end
      end
      # Play main animation
      Graphics.freeze
      Graphics.transition(Graphics.frame_rate*1.25,sprintf("Graphics/Transitions/%s",anim))
      viewport.color = Color.new(0,0,0,255)   # Ensure screen is black
      # Slight pause after animation before starting up the battle scene
      (Graphics.frame_rate/10).times do
        Graphics.update
        Input.update
        pbUpdateSceneMap
      end
    end
    pbPushFade
    # Yield to the battle scene
    yield if block_given?
    # After the battle
    pbPopFade
    if $game_system && $game_system.is_a?(Game_System)
      $game_system.bgm_resume(playingBGM)
      $game_system.bgs_resume(playingBGS)
    end
    $PokemonGlobal.nextBattleBGM       = nil
    $PokemonGlobal.nextBattleME        = nil
    $PokemonGlobal.nextBattleCaptureME = nil
    $PokemonGlobal.nextBattleBack      = nil
    $PokemonEncounters.reset_step_count
    # Fade back to the overworld
    viewport.color = Color.new(0,0,0,255)
    numFrames = Graphics.frame_rate*4/10   # 0.4 seconds, 16 frames
    alphaDiff = (255.0/numFrames).ceil
    numFrames.times do
      viewport.color.alpha -= alphaDiff
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    viewport.dispose
    $game_temp.in_battle = false
  end
  
  #===============================================================================
  # Vs. battle intro animation
  #===============================================================================
  def pbBattleAnimationOverride(viewport,battletype=0,foe=nil)
    ##### VS. animation, by Luka S.J. #####
    ##### Tweaked by Maruno           #####
    if foe.length==1   # Against single trainer
      if (battletype==1 || battletype==3)
        tr_type = foe[0].trainer_type
        if tr_type
          tbargraphic = sprintf("vsBar_%s", tr_type.to_s) rescue nil
          tgraphic    = sprintf("vsTrainer_%s", tr_type.to_s) rescue nil
          if pbResolveBitmap("Graphics/Transitions/" + tbargraphic) && pbResolveBitmap("Graphics/Transitions/" + tgraphic)
            $game_switches[108] = true # Set Style Override
            #player_tr_type = $Trainer.trainer_type
            #outfit = $Trainer.outfit
            # Set up
            viewplayer = Viewport.new(0,Graphics.height/3,Graphics.width/2,128)
            viewplayer.z = viewport.z
            viewopp = Viewport.new(Graphics.width/2,Graphics.height/3,Graphics.width/2,128)
            viewopp.z = viewport.z
            viewvs = Viewport.new(0,0,Graphics.width,Graphics.height)
            viewvs.z = viewport.z
            fade = Sprite.new(viewport)
            fade.bitmap  = RPG::Cache.transition("vsFlash")
            fade.tone    = Tone.new(-255,-255,-255)
            fade.opacity = 100
            overlay = Sprite.new(viewport)
            overlay.bitmap = Bitmap.new(Graphics.width,Graphics.height)
            pbSetSystemFont(overlay.bitmap)
            pbargraphic = sprintf("vsBar_%s", tr_type.to_s) rescue nil
            pbResolveBitmap("Graphics/Transitions/" + pbargraphic)
            #pbargraphic = sprintf("vsBar_%s_%d", player_tr_type.to_s, outfit) rescue nil
            #if !pbResolveBitmap("Graphics/Transitions/" + pbargraphic)
            #  pbargraphic = sprintf("vsBar_%s", player_tr_type.to_s) rescue nil
            #end
            xoffset = ((Graphics.width/2)/10)*10
            bar1 = Sprite.new(viewplayer)
            bar1.bitmap = RPG::Cache.transition(pbargraphic)
            bar1.x      = -xoffset
            bar2 = Sprite.new(viewopp)
            bar2.bitmap = RPG::Cache.transition(tbargraphic)
            bar2.x      = xoffset
            vs = Sprite.new(viewvs)
            vs.bitmap  = RPG::Cache.transition("vs")
            vs.ox      = vs.bitmap.width/2
            vs.oy      = vs.bitmap.height/2
            vs.x       = Graphics.width/2
            vs.y       = Graphics.height/1.5
            vs.visible = false
            flash = Sprite.new(viewvs)
            flash.bitmap  = RPG::Cache.transition("vsFlash")
            flash.opacity = 0
            # Animate bars sliding in from either side
            slideInTime = (Graphics.frame_rate*0.25).floor
            for i in 0...slideInTime
              bar1.x = xoffset*(i+1-slideInTime)/slideInTime
              bar2.x = xoffset*(slideInTime-i-1)/slideInTime
              #pbWait(1)
            end
            bar1.dispose
            bar2.dispose
            # Make whole screen flash white
            pbSEPlay("Vs flash")
            pbSEPlay("Vs sword")
            flash.opacity = 255
            # Replace bar sprites with AnimatedPlanes, set up trainer sprites
            bar1 = AnimatedPlane.new(viewplayer)
            bar1.bitmap = RPG::Cache.transition(pbargraphic)
            bar2 = AnimatedPlane.new(viewopp)
            bar2.bitmap = RPG::Cache.transition(tbargraphic)
            #pgraphic = sprintf("vsTrainer_%s_%d", player_tr_type.to_s, outfit) rescue nil
            #if !pbResolveBitmap("Graphics/Transitions/" + pgraphic)
            #  pgraphic = sprintf("vsTrainer_%s", player_tr_type.to_s) rescue nil
            #end
            #player = Sprite.new(viewplayer)
            #player.bitmap = RPG::Cache.transition(pgraphic)
            #player.x      = -xoffset
            trainer = Sprite.new(viewopp)
            trainer.bitmap = RPG::Cache.transition(tgraphic)
            trainer.x      = xoffset
            trainer.tone   = Tone.new(-255,-255,-255)
            # Dim the flash and make the trainer sprites appear, while animating bars
            animTime = (Graphics.frame_rate*1.2).floor
            for i in 0...animTime
              flash.opacity -= 52*20/Graphics.frame_rate if flash.opacity>0
              #bar1.ox -= 32*20/Graphics.frame_rate
              bar1.ox += 32*20/Graphics.frame_rate
              bar2.ox += 32*20/Graphics.frame_rate
              if i>=animTime/2 && i<slideInTime+animTime/2
                #player.x = xoffset*(i+1-slideInTime-animTime/2)/slideInTime
                trainer.x = xoffset*(slideInTime-i-1+animTime/2)/slideInTime
              end
              pbWait(1)
            end
            #player.x = 0
            trainer.x = 0
            # Make whole screen flash white again
            flash.opacity = 255
            pbSEPlay("Vs sword")
            # Make the Vs logo and trainer names appear, and reset trainer's tone
            vs.visible = true
            trainer.tone = Tone.new(0,0,0)
            trainername = foe[0].name
            textpos = [
               #[$Trainer.name,Graphics.width/4,(Graphics.height/1.5)+4,2,
               #   Color.new(248,248,248),Color.new(12*6,12*6,12*6)],
               [trainername,(Graphics.width/4)+(Graphics.width/2),(Graphics.height/1.5)+10,2,#4,2,
                  Color.new(248,248,248),Color.new(12*6,12*6,12*6)]
            ]
            pbDrawTextPositions(overlay.bitmap,textpos)
            # Fade out flash, shudder Vs logo and expand it, and then fade to black
            animTime = (Graphics.frame_rate*2.75).floor
            shudderTime = (Graphics.frame_rate*1.75).floor
            zoomTime = (Graphics.frame_rate*2.5).floor
            shudderDelta = [4*20/Graphics.frame_rate,1].max
            for i in 0...animTime
              if i<shudderTime   # Fade out the white flash
                flash.opacity -= 52*20/Graphics.frame_rate if flash.opacity>0
              elsif i==shudderTime   # Make the flash black
                flash.tone = Tone.new(-255,-255,-255)
              elsif i>=zoomTime   # Fade to black
                flash.opacity += 52*20/Graphics.frame_rate if flash.opacity<255
              end
              #bar1.ox -= 32*20/Graphics.frame_rate
              bar1.ox += 32*20/Graphics.frame_rate
              bar2.ox += 32*20/Graphics.frame_rate
              if i<shudderTime
                j = i%(2*Graphics.frame_rate/20)
                if j>=0.5*Graphics.frame_rate/20 && j<1.5*Graphics.frame_rate/20
                  vs.x += shudderDelta
                  vs.y -= shudderDelta
                else
                  vs.x -= shudderDelta
                  vs.y += shudderDelta
                end
              elsif i<zoomTime
                vs.zoom_x += 0.4*20/Graphics.frame_rate
                vs.zoom_y += 0.4*20/Graphics.frame_rate
              end
              pbWait(1)
            end
            # End of animation
            #player.dispose
            trainer.dispose
            flash.dispose
            vs.dispose
            bar1.dispose
            bar2.dispose
            overlay.dispose
            fade.dispose
            viewvs.dispose
            viewopp.dispose
            viewplayer.dispose
            viewport.color = Color.new(0,0,0,255)
            return true
          end
        end
      end
    elsif foe.length==2   # Against two trainers
      if (battletype==1 || battletype==3)
        tr1_type = foe[0].trainer_type
        tr2_type = foe[1].trainer_type
        if tr1_type && tr2_type
          t1bargraphic = sprintf("vsBar_%s", tr1_type.to_s) rescue nil
          t2bargraphic = sprintf("vsBar_%s", tr2_type.to_s) rescue nil
          t1graphic    = sprintf("vsTrainer_%s", tr1_type.to_s) rescue nil
          t2graphic    = sprintf("vsTrainer_%s", tr2_type.to_s) rescue nil
          if pbResolveBitmap("Graphics/Transitions/" + t1bargraphic) && pbResolveBitmap("Graphics/Transitions/" + t2bargraphic) &&
             pbResolveBitmap("Graphics/Transitions/" + t1graphic) && pbResolveBitmap("Graphics/Transitions/" + t2graphic)
            $game_switches[108] = true # Set Style Override
            #player_tr_type = $Trainer.trainer_type
            #outfit = $Trainer.outfit
            # Set up
            viewplayer1 = Viewport.new(0,Graphics.height/5-10,Graphics.width,128)
            viewplayer1.z = viewport.z
            viewplayer2 = Viewport.new(0,Graphics.height*3/5-10,Graphics.width,128)
            viewplayer2.z = viewport.z
            viewopp1 = Viewport.new(0,Graphics.height/5-10,Graphics.width,128)
            viewopp1.z = viewport.z
            viewopp2 = Viewport.new(0,Graphics.height*3/5-10,Graphics.width,128)
            viewopp2.z = viewport.z
            viewvs = Viewport.new(0,0,Graphics.width,Graphics.height)
            viewvs.z = viewport.z
            fade = Sprite.new(viewport)
            fade.bitmap  = RPG::Cache.transition("vsFlash")
            fade.tone    = Tone.new(-255,-255,-255)
            fade.opacity = 100
            overlay = Sprite.new(viewport)
            overlay.bitmap = Bitmap.new(Graphics.width,Graphics.height)
            pbSetSystemFont(overlay.bitmap)
            p1bargraphic = sprintf("vsBar_%s", tr1_type.to_s) rescue nil
            p2bargraphic = sprintf("vsBar_%s", tr2_type.to_s) rescue nil
            pbResolveBitmap("Graphics/Transitions/" + p1bargraphic)
            pbResolveBitmap("Graphics/Transitions/" + p2bargraphic)
            #pbargraphic = sprintf("vsBar_%s_%d", player_tr_type.to_s, outfit) rescue nil
            #if !pbResolveBitmap("Graphics/Transitions/" + pbargraphic)
            #  pbargraphic = sprintf("vsBar_%s", player_tr_type.to_s) rescue nil
            #end
            xoffset = ((Graphics.width/2)/10)*10
            bar1 = Sprite.new(viewplayer1)
            bar1.bitmap = RPG::Cache.transition(p1bargraphic)
            bar1.x      = -xoffset
            bar2 = Sprite.new(viewopp1)
            bar2.bitmap = RPG::Cache.transition(t1bargraphic)
            bar2.x      = xoffset
            bar3 = Sprite.new(viewplayer2)
            bar3.bitmap = RPG::Cache.transition(p2bargraphic)
            bar3.x      = -xoffset
            bar4 = Sprite.new(viewopp2)
            bar4.bitmap = RPG::Cache.transition(t2bargraphic)
            bar4.x      = xoffset
            vs = Sprite.new(viewvs)
            vs.bitmap  = RPG::Cache.transition("vs")
            vs.ox      = vs.bitmap.width/2
            vs.oy      = vs.bitmap.height/2
            vs.x       = Graphics.width/2
            vs.y       = Graphics.height/2
            vs.visible = false
            flash = Sprite.new(viewvs)
            flash.bitmap  = RPG::Cache.transition("vsFlash")
            flash.opacity = 0
            # Animate bars sliding in from either side
            slideInTime = (Graphics.frame_rate*0.25).floor
            for i in 0...slideInTime
              bar1.x = xoffset*(i+1-slideInTime)/slideInTime
              bar2.x = xoffset*(slideInTime-i-1)/slideInTime
              bar3.x = xoffset*(i+1-slideInTime)/slideInTime
              bar4.x = xoffset*(slideInTime-i-1)/slideInTime
              #pbWait(1)
            end
            bar1.dispose
            bar2.dispose
            bar3.dispose
            bar4.dispose
            # Make whole screen flash white
            pbSEPlay("Vs flash")
            pbSEPlay("Vs sword")
            flash.opacity = 255
            # Replace bar sprites with AnimatedPlanes, set up trainer sprites
            bar1 = AnimatedPlane.new(viewplayer1)
            bar1.bitmap = RPG::Cache.transition(p1bargraphic)
            bar2 = AnimatedPlane.new(viewopp1)
            bar2.bitmap = RPG::Cache.transition(t1bargraphic)
            bar3 = AnimatedPlane.new(viewplayer2)
            bar3.bitmap = RPG::Cache.transition(p2bargraphic)
            bar4 = AnimatedPlane.new(viewopp2)
            bar4.bitmap = RPG::Cache.transition(t2bargraphic)
            #pgraphic = sprintf("vsTrainer_%s_%d", player_tr_type.to_s, outfit) rescue nil
            #if !pbResolveBitmap("Graphics/Transitions/" + pgraphic)
            #  pgraphic = sprintf("vsTrainer_%s", player_tr_type.to_s) rescue nil
            #end
            #player = Sprite.new(viewplayer)
            #player.bitmap = RPG::Cache.transition(pgraphic)
            #player.x      = -xoffset
            trainer1 = Sprite.new(viewopp1)
            trainer1.bitmap = RPG::Cache.transition(t1graphic)
            trainer1.x      = xoffset#+Graphics.width/2
            trainer1.tone   = Tone.new(-255,-255,-255)
            trainer2 = Sprite.new(viewopp2)
            trainer2.bitmap = RPG::Cache.transition(t2graphic)
            trainer2.x      = xoffset#+Graphics.width/2
            trainer2.tone   = Tone.new(-255,-255,-255)
            # Dim the flash and make the trainer sprites appear, while animating bars
            animTime = (Graphics.frame_rate*1.2).floor
            for i in 0...animTime
              flash.opacity -= 52*20/Graphics.frame_rate if flash.opacity>0
              #bar1.ox -= 32*20/Graphics.frame_rate
              bar1.ox += 32*20/Graphics.frame_rate
              bar2.ox += 32*20/Graphics.frame_rate
              bar3.ox += 32*20/Graphics.frame_rate
              bar4.ox += 32*20/Graphics.frame_rate
              if i>=animTime/2 && i<slideInTime+animTime/2
                #player.x = xoffset*(i+1-slideInTime-animTime/2)/slideInTime
                #trainer1.x = xoffset*(slideInTime-i-1+animTime)/slideInTime
                #trainer2.x = xoffset*(slideInTime-i-1+animTime)/slideInTime
              end
              pbWait(1)
            end
            #player.x = 0
            #trainer1.x = 0
            #trainer2.x = 0
            # Make whole screen flash white again
            flash.opacity = 255
            pbSEPlay("Vs sword")
            # Make the Vs logo and trainer names appear, and reset trainer's tone
            vs.visible = true
            trainer1.tone = Tone.new(0,0,0)
            trainer2.tone = Tone.new(0,0,0)
  =begin
            trainername = foe[0].name
            textpos = [
               #[$Trainer.name,Graphics.width/4,(Graphics.height/1.5)+4,2,
               #   Color.new(248,248,248),Color.new(12*6,12*6,12*6)],
               [trainername,(Graphics.width/4)+(Graphics.width/2),(Graphics.height/1.5)+10,2,#4,2,
                  Color.new(248,248,248),Color.new(12*6,12*6,12*6)]
            ]
            pbDrawTextPositions(overlay.bitmap,textpos)
  =end
            # Fade out flash, shudder Vs logo and expand it, and then fade to black
            animTime = (Graphics.frame_rate*2.75).floor
            shudderTime = (Graphics.frame_rate*1.75).floor
            zoomTime = (Graphics.frame_rate*2.5).floor
            shudderDelta = [4*20/Graphics.frame_rate,1].max
            for i in 0...animTime
              if i<shudderTime   # Fade out the white flash
                flash.opacity -= 52*20/Graphics.frame_rate if flash.opacity>0
              elsif i==shudderTime   # Make the flash black
                flash.tone = Tone.new(-255,-255,-255)
              elsif i>=zoomTime   # Fade to black
                flash.opacity += 52*20/Graphics.frame_rate if flash.opacity<255
              end
              #bar1.ox -= 32*20/Graphics.frame_rate
              bar1.ox += 32*20/Graphics.frame_rate
              bar2.ox += 32*20/Graphics.frame_rate
              bar3.ox += 32*20/Graphics.frame_rate
              bar4.ox += 32*20/Graphics.frame_rate
              if i<shudderTime
                j = i%(2*Graphics.frame_rate/20)
                if j>=0.5*Graphics.frame_rate/20 && j<1.5*Graphics.frame_rate/20
                  vs.x += shudderDelta
                  vs.y -= shudderDelta
                else
                  vs.x -= shudderDelta
                  vs.y += shudderDelta
                end
              elsif i<zoomTime
                vs.zoom_x += 0.4*20/Graphics.frame_rate
                vs.zoom_y += 0.4*20/Graphics.frame_rate
              end
              pbWait(1)
            end
            # End of animation
            #player.dispose
            trainer1.dispose
            trainer2.dispose
            flash.dispose
            vs.dispose
            bar1.dispose
            bar2.dispose
            bar3.dispose
            bar4.dispose
            overlay.dispose
            fade.dispose
            viewvs.dispose
            viewopp1.dispose
            viewopp2.dispose
            viewplayer1.dispose
            viewplayer2.dispose
            viewport.color = Color.new(0,0,0,255)
            return true
          end
        end
      end
    elsif foe.length==3   # Against three trainers
      if (battletype==1 || battletype==3)
        tr1_type = foe[0].trainer_type
        tr2_type = foe[1].trainer_type
        tr3_type = foe[2].trainer_type
        if tr1_type && tr2_type && tr3_type
          t1bargraphic = sprintf("vsBar_%s", tr1_type.to_s) rescue nil
          t1graphic    = sprintf("vsTrainer_%s", tr1_type.to_s) rescue nil
          t2bargraphic = sprintf("vsBar_%s", tr2_type.to_s) rescue nil
          t2graphic    = sprintf("vsTrainer_%s", tr2_type.to_s) rescue nil
          t3bargraphic = sprintf("vsBar_%s", tr3_type.to_s) rescue nil
          t3graphic    = sprintf("vsTrainer_%s", tr3_type.to_s) rescue nil
          if pbResolveBitmap("Graphics/Transitions/" + t1bargraphic) && pbResolveBitmap("Graphics/Transitions/" + t1graphic) &&
             pbResolveBitmap("Graphics/Transitions/" + t2bargraphic) && pbResolveBitmap("Graphics/Transitions/" + t2graphic) &&
             pbResolveBitmap("Graphics/Transitions/" + t3bargraphic) && pbResolveBitmap("Graphics/Transitions/" + t3graphic)
            $game_switches[108] = true # Set Style Override
            #player_tr_type = $Trainer.trainer_type
            #outfit = $Trainer.outfit
            # Set up
            viewplayer1 = Viewport.new(0,Graphics.height/5-10,Graphics.width,128)
            viewplayer1.z = viewport.z
            viewplayer2 = Viewport.new(0,Graphics.height*3/5-10,Graphics.width,128)
            viewplayer2.z = viewport.z
            viewplayer3 = Viewport.new(0,Graphics.height*3/5-10,Graphics.width,128)
            viewplayer3.z = viewport.z
            viewopp1 = Viewport.new(0,Graphics.height/5-10,Graphics.width,128)
            viewopp1.z = viewport.z
            viewopp2 = Viewport.new(0,Graphics.height*3/5-10,Graphics.width,128)
            viewopp2.z = viewport.z
            viewopp3 = Viewport.new(0,Graphics.height*3/5-10,Graphics.width,128)
            viewopp3.z = viewport.z
            viewvs = Viewport.new(0,0,Graphics.width,Graphics.height)
            viewvs.z = viewport.z
            fade = Sprite.new(viewport)
            fade.bitmap  = RPG::Cache.transition("vsFlash")
            fade.tone    = Tone.new(-255,-255,-255)
            fade.opacity = 100
            overlay = Sprite.new(viewport)
            overlay.bitmap = Bitmap.new(Graphics.width,Graphics.height)
            pbSetSystemFont(overlay.bitmap)
            p1bargraphic = sprintf("vsBar_%s", tr1_type.to_s) rescue nil
            p2bargraphic = sprintf("vsBar_%s", tr2_type.to_s) rescue nil
            p3bargraphic = sprintf("vsBar_%s", tr3_type.to_s) rescue nil
            pbResolveBitmap("Graphics/Transitions/" + p1bargraphic)
            pbResolveBitmap("Graphics/Transitions/" + p2bargraphic)
            pbResolveBitmap("Graphics/Transitions/" + p3bargraphic)
            #pbargraphic = sprintf("vsBar_%s_%d", player_tr_type.to_s, outfit) rescue nil
            #if !pbResolveBitmap("Graphics/Transitions/" + pbargraphic)
            #  pbargraphic = sprintf("vsBar_%s", player_tr_type.to_s) rescue nil
            #end
            xoffset = ((Graphics.width/2)/10)*10
            bar1 = Sprite.new(viewplayer1)
            bar1.bitmap = RPG::Cache.transition(p1bargraphic)
            bar1.x      = -xoffset
            bar2 = Sprite.new(viewopp1)
            bar2.bitmap = RPG::Cache.transition(t1bargraphic)
            bar2.x      = xoffset
            bar3 = Sprite.new(viewplayer2)
            bar3.bitmap = RPG::Cache.transition(p2bargraphic)
            bar3.x      = -xoffset
            bar4 = Sprite.new(viewopp2)
            bar4.bitmap = RPG::Cache.transition(t2bargraphic)
            bar4.x      = xoffset
            bar5 = Sprite.new(viewplayer3)
            bar5.bitmap = RPG::Cache.transition(p3bargraphic)
            bar5.x      = -xoffset
            bar6 = Sprite.new(viewopp3)
            bar6.bitmap = RPG::Cache.transition(t3bargraphic)
            bar6.x      = xoffset
            vs = Sprite.new(viewvs)
            vs.bitmap  = RPG::Cache.transition("vs")
            vs.ox      = vs.bitmap.width/2
            vs.oy      = vs.bitmap.height/2
            vs.x       = Graphics.width/2
            vs.y       = Graphics.height/2
            vs.visible = false
            flash = Sprite.new(viewvs)
            flash.bitmap  = RPG::Cache.transition("vsFlash")
            flash.opacity = 0
            # Animate bars sliding in from either side
            slideInTime = (Graphics.frame_rate*0.25).floor
            for i in 0...slideInTime
              bar1.x = xoffset*(i+1-slideInTime)/slideInTime
              bar2.x = xoffset*(slideInTime-i-1)/slideInTime
              bar3.x = xoffset*(i+1-slideInTime)/slideInTime
              bar4.x = xoffset*(slideInTime-i-1)/slideInTime
              bar5.x = xoffset*(i+1-slideInTime)/slideInTime
              bar6.x = xoffset*(slideInTime-i-1)/slideInTime
              #pbWait(1)
            end
            bar1.dispose
            bar2.dispose
            bar3.dispose
            bar4.dispose
            bar5.dispose
            bar6.dispose
            # Make whole screen flash white
            pbSEPlay("Vs flash")
            pbSEPlay("Vs sword")
            flash.opacity = 255
            # Replace bar sprites with AnimatedPlanes, set up trainer sprites
            bar1 = AnimatedPlane.new(viewplayer1)
            bar1.bitmap = RPG::Cache.transition(p1bargraphic)
            bar2 = AnimatedPlane.new(viewopp1)
            bar2.bitmap = RPG::Cache.transition(t1bargraphic)
            bar3 = AnimatedPlane.new(viewplayer2)
            bar3.bitmap = RPG::Cache.transition(p2bargraphic)
            bar4 = AnimatedPlane.new(viewopp2)
            bar4.bitmap = RPG::Cache.transition(t2bargraphic)
            bar5 = AnimatedPlane.new(viewplayer3)
            bar5.bitmap = RPG::Cache.transition(p3bargraphic)
            bar6 = AnimatedPlane.new(viewopp3)
            bar6.bitmap = RPG::Cache.transition(t3bargraphic)
            #pgraphic = sprintf("vsTrainer_%s_%d", player_tr_type.to_s, outfit) rescue nil
            #if !pbResolveBitmap("Graphics/Transitions/" + pgraphic)
            #  pgraphic = sprintf("vsTrainer_%s", player_tr_type.to_s) rescue nil
            #end
            #player = Sprite.new(viewplayer)
            #player.bitmap = RPG::Cache.transition(pgraphic)
            #player.x      = -xoffset
            trainer1 = Sprite.new(viewopp1)
            trainer1.bitmap = RPG::Cache.transition(t1graphic)
            trainer1.x      = xoffset#+Graphics.width/2
            trainer1.tone   = Tone.new(-255,-255,-255)
            trainer2 = Sprite.new(viewopp2)
            trainer2.bitmap = RPG::Cache.transition(t2graphic)
            trainer2.x      = xoffset#+Graphics.width/2
            trainer2.tone   = Tone.new(-255,-255,-255)
            trainer3 = Sprite.new(viewopp2)
            trainer3.bitmap = RPG::Cache.transition(t2graphic)
            trainer3.x      = xoffset#+Graphics.width/2
            trainer3.tone   = Tone.new(-255,-255,-255)
            # Dim the flash and make the trainer sprites appear, while animating bars
            animTime = (Graphics.frame_rate*1.2).floor
            for i in 0...animTime
              flash.opacity -= 52*20/Graphics.frame_rate if flash.opacity>0
              #bar1.ox -= 32*20/Graphics.frame_rate
              bar1.ox += 32*20/Graphics.frame_rate
              bar2.ox += 32*20/Graphics.frame_rate
              bar3.ox += 32*20/Graphics.frame_rate
              bar4.ox += 32*20/Graphics.frame_rate
              bar5.ox += 32*20/Graphics.frame_rate
              bar6.ox += 32*20/Graphics.frame_rate
              if i>=animTime/2 && i<slideInTime+animTime/2
                #player.x = xoffset*(i+1-slideInTime-animTime/2)/slideInTime
                #trainer1.x = xoffset*(slideInTime-i-1+animTime)/slideInTime
                #trainer2.x = xoffset*(slideInTime-i-1+animTime)/slideInTime
              end
              pbWait(1)
            end
            #player.x = 0
            #trainer1.x = 0
            #trainer2.x = 0
            #trainer3.x = 0
            # Make whole screen flash white again
            flash.opacity = 255
            pbSEPlay("Vs sword")
            # Make the Vs logo and trainer names appear, and reset trainer's tone
            vs.visible = true
            trainer1.tone = Tone.new(0,0,0)
            trainer2.tone = Tone.new(0,0,0)
            trainer3.tone = Tone.new(0,0,0)
  =begin
            trainername = foe[0].name
            textpos = [
               #[$Trainer.name,Graphics.width/4,(Graphics.height/1.5)+4,2,
               #   Color.new(248,248,248),Color.new(12*6,12*6,12*6)],
               [trainername,(Graphics.width/4)+(Graphics.width/2),(Graphics.height/1.5)+10,2,#4,2,
                  Color.new(248,248,248),Color.new(12*6,12*6,12*6)]
            ]
            pbDrawTextPositions(overlay.bitmap,textpos)
  =end
            # Fade out flash, shudder Vs logo and expand it, and then fade to black
            animTime = (Graphics.frame_rate*2.75).floor
            shudderTime = (Graphics.frame_rate*1.75).floor
            zoomTime = (Graphics.frame_rate*2.5).floor
            shudderDelta = [4*20/Graphics.frame_rate,1].max
            for i in 0...animTime
              if i<shudderTime   # Fade out the white flash
                flash.opacity -= 52*20/Graphics.frame_rate if flash.opacity>0
              elsif i==shudderTime   # Make the flash black
                flash.tone = Tone.new(-255,-255,-255)
              elsif i>=zoomTime   # Fade to black
                flash.opacity += 52*20/Graphics.frame_rate if flash.opacity<255
              end
              #bar1.ox -= 32*20/Graphics.frame_rate
              bar1.ox += 32*20/Graphics.frame_rate
              bar2.ox += 32*20/Graphics.frame_rate
              bar3.ox += 32*20/Graphics.frame_rate
              bar4.ox += 32*20/Graphics.frame_rate
              bar5.ox += 32*20/Graphics.frame_rate
              bar6.ox += 32*20/Graphics.frame_rate
              if i<shudderTime
                j = i%(2*Graphics.frame_rate/20)
                if j>=0.5*Graphics.frame_rate/20 && j<1.5*Graphics.frame_rate/20
                  vs.x += shudderDelta
                  vs.y -= shudderDelta
                else
                  vs.x -= shudderDelta
                  vs.y += shudderDelta
                end
              elsif i<zoomTime
                vs.zoom_x += 0.4*20/Graphics.frame_rate
                vs.zoom_y += 0.4*20/Graphics.frame_rate
              end
              pbWait(1)
            end
            # End of animation
            #player.dispose
            trainer1.dispose
            trainer2.dispose
            trainer3.dispose
            flash.dispose
            vs.dispose
            bar1.dispose
            bar2.dispose
            bar3.dispose
            bar4.dispose
            bar5.dispose
            bar6.dispose
            overlay.dispose
            fade.dispose
            viewvs.dispose
            viewopp1.dispose
            viewopp2.dispose
            viewopp3.dispose
            viewplayer1.dispose
            viewplayer2.dispose
            viewplayer3.dispose
            viewport.color = Color.new(0,0,0,255)
            return true
          end
        end
      end
    end
    return false
  end
  
  #===============================================================================
  # Override battle intro animation
  #===============================================================================
  # If you want to add a custom battle intro animation, copy the following alias
  # line and method into a new script section. Change the name of the alias part
  # ("__over1__") in your copied code in both places. Then add in your custom
  # transition code in the place shown.
  # Note that $game_temp.background_bitmap contains an image of the current game
  # screen.
  # When the custom animation has finished, the screen should have faded to black
  # somehow.
  
  alias __over1__pbBattleAnimationOverride pbBattleAnimationOverride
  
  def pbBattleAnimationOverride(viewport,battletype=0,foe=nil)
    # The following example runs a common event that ought to do a custom
    # animation if some condition is true:
    #
    # if $game_map.map_id==20   # If on map 20
    #   pbCommonEvent(20)
    #   return true             # Note that the battle animation is done
    # end
    #
    # The following line needs to call the aliased method if the custom transition
    # animation was NOT shown.
    return __over1__pbBattleAnimationOverride(viewport,battletype,foe)
  end
  