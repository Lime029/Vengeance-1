#===============================================================================
#  New animated and modular Title Screen for Pokemon Essentials
#    by Luka S.J.
#
#  ONLY FOR Essentials v19.x
# ----------------
#  Configuration constants for the script. All the various constants have been
#  commented to label what each of them does. Please make sure to read what
#  they do, and how to use them. Most of this script is just green text.
#
#  A lot of time and effort went into making this an extensive and comprehensive
#  resource. So please be kind enough to give credit when using it.
#
#  Please consult the official documentation page to learn how to set up
#  your animated title screens: https://luka-sj.com/res/modts/docs
#===============================================================================
module ModularTitle
    # Configuration constant used to style the Title Screen
    # Add multiple modifiers to add visual effects to the Title Screen
    # Non additive modifiers do not stack i.e. you can only use one of each type
    MODIFIERS = [
    #-------------------------------------------------------------------------------
    #                                  PRESETS
    #-------------------------------------------------------------------------------
      # Electric Nightmare
      #"background1", "logo:bounce", "effect9", "logo:shine", "intro:4"
  
      # Trainer Adventure
      #"background6", "misc1", "overlay5", "effect8", "logo:glow", "bgm:title_hgss", "intro:2"
  
      # Enter the Ultra Wormhole
      #"background2", "effect1", "effect5", "overlay:static003", "logo:glow", "intro:7"
  
      # Ugly Rainbow
      #"background5", "logo:sparkle", "overlay:static004", "effect1", "intro:5"
  
      # Ocean Breeze
      #"background11", "intro:1", "logoY:172", "logo:sparkle", "logo:shine", "overlay:blue_z25", "misc5:blastoise_x294_y118", "effect5_y106", "effect4_y106", "bgm:title_frlg"
  
      # Evolution
      #"background8", "effect7_y272", "effect6_y272", "effect4_y272", "effect5_y272", "logoY:172", "misc4_y312", "overlay5", "bgm:title_rse", "intro:3"
  
      # Burning Red (gen 1)
      #"background:frlg", "intro:1", "effect10_y308", "overlay:frlg", "logoX:204", "logoY:164", "logo:sparkle", "misc5:charizard_x284_y142", "bgm:title_frlg"
  
      # Heart of Gold (gen 2)
      #"background:dawn", "intro:2", "logoY:172", "logo:glow", "misc2", "effect11_x368_y112", "effect6_x368_y112", "effect4_x368_y112", "overlay3", "bgm:title_hgss"
  
      # Sapphire Abyss (gen 3)
      #"background:rse", "intro:3", "misc3_x260_y236", "overlay4", "logoY:172", "logo:sparkle", "logo:shine", "effect3_y236", "bgm:title_rse"
  
      # Platinum Shade (gen 4)
      #"background10", "intro:4", "overlay7", "bgm:title_dppt", "logoY:172"
  
      # Dark Display (gen 5)
      #"background:bw", "overlay2", "logoY:172", "logo:shine", "misc4_s2_x284_y339", "effect6_y312", "bgm:title_bw"
  
      # Forest Sky (gen 6)
      #"background4", "intro:6", "effect4", "effect5", "effect7", "overlay:static002", "bgm:title_xy"
  
      # Cosmic Vibes (gen 7)
      #"background3", "intro:7", "effect5", "effect6", "overlay6", "logo:shine", "bgm:title_sm"
    #-------------------------------------------------------------------------------
    #                  V V     add your modifiers in here     V V
    #-------------------------------------------------------------------------------
  "background10","overlay6","overlay:Capture","effect11","effect1","effect3","effect4"
  
    ] # end of config constant
    #-------------------------------------------------------------------------------
    # Other config
    #-------------------------------------------------------------------------------
    # Config used for determining the cry of species to play, along with displaying
    # a certain Pokemon sprite if applicable. Leave it as nil in order not to play
    # a species cry, otherwise set as a symbolic value
    SPECIES = :DECIDUEYE
    # Applies a form to Pokemon species
    SPECIES_FORM = 0
    # Applies female form
    SPECIES_FEMALE = false
    # Applies shiny variant
    SPECIES_SHINY = false
    # Applies backsprite
    SPECIES_BACK = false
  
    # Config to reposition the "Press Enter" text across the screen
    # keep values at nil to keep at default position
    # format is [x,y]
    START_POS = [nil, nil]
  
    # set to true to show Title Screen even when running the game in Debug mode
    SHOW_IN_DEBUG = false
  
  end
  
  #===============================================================================
  # Static and animated title screen backgrounds
  #===============================================================================
  # Static
  class MTS_Element_BG0
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil)
      @viewport = viewport
      @disposed = false
      @sprites = {}
      file = "background" if file.nil?
      # creates the background layer
      @sprites["bg"] = Sprite.new(@viewport)
      @sprites["bg"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/#{file}")
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # visibility (not applicable)
    def visible; end
    def visible=(val); end
    # update method
    def update; end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Digital
  class MTS_Element_BG1
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil)
      @viewport = viewport
      @disposed = false
      @speed = 1
      @sprites = {}
      @tiles = []
      @data = []
      # creates the background layer
      @sprites["bg"] = Sprite.new(@viewport)
      @sprites["bg"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/digital")
      # analyzes background
      f = 16
      avg = 0
      n = 0
      for x in 0...@sprites["bg"].bitmap.width/f
        for y in 0...@sprites["bg"].bitmap.height/f
          px = @sprites["bg"].bitmap.get_pixel(x*f,y*f)
          avg += (px.red + px.green + px.blue)/3.0
          n += 1
        end
      end
      tc = (avg/n) > 128 ? Color.white : Color.black
      # draws all the little tiles
      tile_size = 32.0
      opacity = 55
      offset = 0
      @x = (@viewport.rect.width/tile_size).ceil
      @y = (@viewport.rect.height/tile_size).ceil
      for i in 0...@x
        for j in 0...@y
          sprite = Sprite.new(@viewport)
          sprite.bitmap = Bitmap.new(tile_size,tile_size)
          sprite.bitmap.fill_rect(offset,offset,tile_size-offset*2,tile_size-offset*2,Color.new(tc.red,tc.green,tc.blue,opacity))
          sprite.x = i * tile_size
          sprite.y = j * tile_size
          o = opacity + rand(156)
          sprite.opacity = 0
          @tiles.push(sprite)
          @data.push([o,rand(4)+2])
        end
      end
    end
    # updates the background
    def update(skip=false)
      return if self.disposed?
      for i in 0...@tiles.length
        @tiles[i].opacity += @data[i][1]
        @data[i][1] *= -1 if @tiles[i].opacity <= 0 || @tiles[i].opacity >= @data[i][0]
      end
    end
    # visibility (not applicable)
    def visible; end
    def visible=(val); end
    # disposes of everything
    def dispose
      @disposed = true
      for tile in @tiles
        tile.dispose
      end
      pbDisposeSpriteHash(@sprites)
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Ultra Beast
  class MTS_Element_BG2
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      @sprites = {}
      # creates the background layer
      @sprites["bg"] = RainbowSprite.new(@viewport)
      @sprites["bg"].setBitmap("Graphics/MODTS/Backgrounds/radiant")
      # creates the circular zoom patterns
      for i in 0...8
        @sprites["h#{i}"] = Sprite.new(@viewport)
        @sprites["h#{i}"].bitmap = pbBitmap("Graphics/MODTS/Particles/ring001")
        @sprites["h#{i}"].center!
        @sprites["h#{i}"].x = @viewport.rect.width/2
        @sprites["h#{i}"].y = @viewport.rect.height/2
        @sprites["h#{i}"].opacity = 0
      end
      # cycles the BG a bit to position the circular patterns
      256.times do
        self.update(true)
      end
    end
    # updates the background
    def update(skip=false)
      return if self.disposed?
      @sprites["bg"].update unless skip
      for i in 0...8
        next if i > @fpIndex/32
        if @sprites["h#{i}"].opacity <= 0
          @sprites["h#{i}"].zoom_x = 1
          @sprites["h#{i}"].zoom_y = 1
          @sprites["h#{i}"].opacity = 255
        end
        @sprites["h#{i}"].zoom_x += 0.003*(@sprites["h#{i}"].zoom_x**2)
        @sprites["h#{i}"].zoom_y += 0.003*(@sprites["h#{i}"].zoom_y**2)
        @sprites["h#{i}"].opacity -= 1
      end
      @fpIndex += 1 if @fpIndex < 512
    end
    # visibility (not applicable)
    def visible; end
    def visible=(val); end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Space dust
  class MTS_Element_BG3
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil)
      @viewport = viewport
      @disposed = false
      @sprites = {}
      @fpIndex = 0
      # creates the background
      @sprites["bg1"] = Sprite.new(@viewport)
      @sprites["bg1"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/clouded")
      @sprites["bg1"].center!
      @sprites["bg1"].x = @viewport.rect.width/2
      @sprites["bg1"].y = @viewport.rect.height/2
      # creates additional set of graphic
      @sprites["bg2"] = Sprite.new(@viewport)
      @sprites["bg2"].bitmap = pbBitmap("Graphics/MODTS/Particles/ring003")
      @sprites["bg2"].center!
      @sprites["bg2"].x = @viewport.rect.width/2
      @sprites["bg2"].y = @viewport.rect.height/2
    end
    # updates the background
    def update
      return if self.disposed?
      # background and shine
      @sprites["bg1"].angle += 1 if $PokemonSystem.screensize < 2
      @sprites["bg2"].angle -= 1 if $PokemonSystem.screensize < 2
      @fpIndex += 1 if @fpIndex < 150
    end
    # visibility (not applicable)
    def visible; end
    def visible=(val); end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # XY bg
  class MTS_Element_BG4
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      @sprites = {}
      # creates the background layer
      @sprites["bg"] = Sprite.new(@viewport)
      @sprites["bg"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/dusk")
      # creates glow
      @tog = 1
      @sprites["glow"] = Sprite.new(@viewport)
      @sprites["glow"].bitmap = pbBitmap("Graphics/MODTS/Particles/glow001")
      # creates spinning element
      @sprites["rad"] = Sprite.new(@viewport)
      @sprites["rad"].bitmap = pbBitmap("Graphics/MODTS/Particles/radial001")
      @sprites["rad"].center!(true)
    end
    # updates the background
    def update(skip=false)
      return if self.disposed?
      @sprites["rad"].angle += 1 if $PokemonSystem.screensize < 2
      @sprites["glow"].opacity -= @tog
      @tog *= -1 if @sprites["glow"].opacity <= 125 || @sprites["glow"].opacity >= 255
      @fpIndex += 1 if @fpIndex < 512
    end
    # visibility (not applicable)
    def visible; end
    def visible=(val); end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Rainbow
  class MTS_Element_BG5
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      @sprites = {}
      # creates the background layer
      @sprites["bg"] = RainbowSprite.new(@viewport)
      @sprites["bg"].setBitmap("Graphics/MODTS/Backgrounds/rainbow")
    end
    # updates the background
    def update(skip=false)
      return if self.disposed?
      @sprites["bg"].update unless skip
      @fpIndex += 1 if @fpIndex < 512
    end
    # visibility (not applicable)
    def visible; end
    def visible=(val); end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Panorama
  class MTS_Element_BG6
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      @sprites = {}
      # creates the background layer
      @sprites["bg"] = Sprite.new(viewport)
      @sprites["bg"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/sky")
      @sprites["clouds"] = ScrollingSprite.new(viewport)
      @sprites["clouds"].setBitmap("Graphics/MODTS/Panorama/clouds")
      @sprites["clouds"].speed = 1
      @sprites["clouds"].direction = -1
      @sprites["mountains"] = Sprite.new(viewport)
      @sprites["mountains"].bitmap = pbBitmap("Graphics/MODTS/Panorama/mountains")
      for i in 1..3
        m = 4-i
        @sprites["trees#{m}"] = ScrollingSprite.new(@viewport)
        @sprites["trees#{m}"].setBitmap(sprintf("Graphics/MODTS/Panorama/trees%03d",m))
        @sprites["trees#{m}"].speed = m*2
        @sprites["trees#{m}"].direction = -1
      end
      @sprites["grass"] = ScrollingSprite.new(viewport)
      @sprites["grass"].setBitmap("Graphics/MODTS/Panorama/grass")
      @sprites["grass"].speed = 4
      @sprites["grass"].direction = -1
    end
    # updates the background
    def update(skip=false)
      return if self.disposed?
      for key in @sprites.keys
        @sprites[key].update
      end
      @fpIndex += 1 if @fpIndex < 512
    end
    # visibility (not applicable)
    def visible; end
    def visible=(val); end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Crazy
  class MTS_Element_BG7
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      @sprites = {}
      # creates the background layer
      @sprites["bg"] = Sprite.new(@viewport)
      @sprites["bg"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
      # draws the 3 circular patterns that change hue
      for j in 0...3
        @sprites["b#{j}"] = RainbowSprite.new(@viewport)
        @sprites["b#{j}"].setBitmap(sprintf("Graphics/MODTS/Particles/ring%03d",j+4),8)
        @sprites["b#{j}"].center!(true)
        @sprites["b#{j}"].zoom_x = 0.6 + 0.6*j
        @sprites["b#{j}"].zoom_y = 0.6 + 0.6*j
        @sprites["b#{j}"].opacity = 64 + 64*(1+j)
      end
    end
    # updates the background
    def update(skip=false)
      return if self.disposed?
      # updates the 3 circular patterns changing their hue
      for j in 0...3
        @sprites["b#{j}"].zoom_x -= 0.025
        @sprites["b#{j}"].zoom_y -= 0.025
        @sprites["b#{j}"].opacity -= 4
        if @sprites["b#{j}"].zoom_x <= 0 || @sprites["b#{j}"].opacity <= 0
          @sprites["b#{j}"].zoom_x = 2.25
          @sprites["b#{j}"].zoom_y = 2.25
          @sprites["b#{j}"].opacity = 255
        end
        @sprites["b#{j}"].update if @fpIndex%8==0
      end
      @fpIndex += 1
      @fpIndex = 0 if @fpIndex >= 64
    end
    # visibility (not applicable)
    def visible; end
    def visible=(val); end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Evolution
  class MTS_Element_BG8
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      @sprites = {}
      # background graphics
      @sprites["bg1"] = Sprite.new(@viewport)
      @sprites["bg1"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/evolution")
      # particles for the background
      for j in 0...6
        @sprites["l#{j}"] = Sprite.new(@viewport)
        @sprites["l#{j}"].bitmap = pbBitmap("Graphics/MODTS/Particles/ray004")
        @sprites["l#{j}"].y = (@viewport.rect.height/6)*j
        @sprites["l#{j}"].ox = @sprites["l#{j}"].bitmap.width/2
        @sprites["l#{j}"].x = @viewport.rect.width/2
      end
    end
    # updates the background
    def update(skip=false)
      return if self.disposed?
      # updates line movement
      for j in 0...6
        @sprites["l#{j}"].y = @viewport.rect.height if @sprites["l#{j}"].y <= 0
        t = (@sprites["l#{j}"].y.to_f/@viewport.rect.height)*255
        @sprites["l#{j}"].tone = Tone.new(t,t,t)
        z = ((@sprites["l#{j}"].y.to_f - @viewport.rect.height/2)/(@viewport.rect.height/2))*1.0
        @sprites["l#{j}"].angle = (z < 0) ? 180 : 0
        @sprites["l#{j}"].zoom_y = z.abs
        @sprites["l#{j}"].y -= 2
      end
      @fpIndex += 1
      @fpIndex = 0 if @fpIndex >= 64
    end
    # visibility (not applicable)
    def visible; end
    def visible=(val); end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Ethereal
  class MTS_Element_BG9
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      @sprites = {}
      # background graphics
      @sprites["bg1"] = Sprite.new(@viewport)
      @sprites["bg1"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/ethereal")
      # particles for the ripple
      for j in 0...4
        @sprites["r#{j}"] = Sprite.new(@viewport)
        @sprites["r#{j}"].bitmap = pbBitmap("Graphics/MODTS/Particles/special005")
        @sprites["r#{j}"].center!
        @sprites["r#{j}"].x = @sprites["bg1"].bitmap.width/2
        @sprites["r#{j}"].y = @sprites["bg1"].bitmap.height*0.84
        @sprites["r#{j}"].zoom_x = 0
        @sprites["r#{j}"].zoom_y = 0
        @sprites["r#{j}"].opacity = 0
      end
    end
    # updates the background
    def update(skip=false)
      return if self.disposed?
      # updates line ripple
      for j in 0...4
        next if j > @fpIndex/32
        if @sprites["r#{j}"].opacity <= 0
          @sprites["r#{j}"].opacity = 255
          @sprites["r#{j}"].zoom_x = 0
          @sprites["r#{j}"].zoom_y = 0
        end
        @sprites["r#{j}"].zoom_x += 0.01
        @sprites["r#{j}"].zoom_y += 0.01
        @sprites["r#{j}"].opacity -= 2
      end
      @fpIndex += 1 if @fpIndex < 256
    end
    # visibility (not applicable)
    def visible; end
    def visible=(val); end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Silhouette
  class MTS_Element_BG10
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      @speed = 8
      @sprites = {}
      # background graphics
      @sprites["bg"] = Sprite.new(@viewport)
      @sprites["bg"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
      # streak
      @sprites["streak"] = Sprite.new(@viewport)
      @sprites["streak"].bitmap = pbBitmap("Graphics/MODTS/Panorama/streak")
      @sprites["streak"].y = @viewport.rect.height*3
      # silhouette
      @sprites["sil"] = Sprite.new(@viewport)
      @sprites["sil"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/silhouette")
      @sprites["sil"].src_rect.width = @viewport.rect.width
    end
    # updates the background
    def update(skip=false)
      return if self.disposed?
      @sprites["streak"].y -= 16.delta(:sub)
      @sprites["streak"].y = @viewport.rect.height if @sprites["streak"].y < -@viewport.rect.height*16
      @sprites["sil"].src_rect.x += @sprites["sil"].src_rect.width if @fpIndex%@speed == 0
      @sprites["sil"].src_rect.x = 0 if @sprites["sil"].src_rect.x >= @sprites["sil"].bitmap.width
      @fpIndex += 1 
      @fpIndex = 0 if @fpIndex > @speed
    end
    # visibility (not applicable)
    def visible; end
    def visible=(val); end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Scrolling: left
  class MTS_Element_BG11
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil)
      @viewport = viewport
      @disposed = false
      file = "scrolling" if file.nil?
      @sprites = {}
      # creates the background layer
      @sprites["bg"] = ScrollingSprite.new(@viewport)
      @sprites["bg"].setBitmap("Graphics/MODTS/Backgrounds/"+file)
      @sprites["bg"].speed = 1
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # visibility (not applicable)
    def visible; end
    def visible=(val); end
    # update method
    def update
      return if self.disposed?
      @sprites["bg"].update
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  
  #-------------------------------------------------------------------------------
  # Crystal
  class MTS_Element_BG12
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil)
      @viewport = viewport
      @disposed = false
      @sprites = {}
      # creates the background layer
      @sprites["bg"] = Sprite.new(@viewport)
      @sprites["bg"].bitmap = pbBitmap("Graphics/MODTS/Backgrounds/crystal")
      @sprites["cr"] = MTS_Extra_Overlay.new(@viewport)
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # visibility (not applicable)
    def visible; end
    def visible=(val); end
    # update method
    def update
      return if self.disposed?
      @sprites["cr"].update
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #===============================================================================
  
  #===============================================================================
  # Animated particles and visual effects
  #===============================================================================
  # Rays: style 1
  class MTS_Element_FX1
    attr_accessor :x, :y
    def id; return "effect.rays"; end
    def id?(val); return self.id == val; end
    # main method to create the effect
    def initialize(viewport,x=nil,y=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @sprites = {}
      # initializes the required sprites
      for i in 0...16
        @sprites["r#{i}"] = Sprite.new(@viewport)
        @sprites["r#{i}"].opacity = 0
        @sprites["r#{i}"].z = z.nil? ? 30 : z
      end
    end
    # positions effect on screen
  =begin
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height/2 : y
    end
  =end
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/8 : x
      @y = y.nil? ? @viewport.rect.height+@viewport.rect.width/12 : y
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # changes visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
      end
    end
    # update method
    def update
      return if self.disposed?
      # updates ray particles
      for j in 0...16
        next if j > @fpIndex/2
        if @sprites["r#{j}"].opacity <= 0
          bmp = pbBitmap("Graphics/MODTS/Particles/ray001")
          w = rand(65) + 16
          @sprites["r#{j}"].bitmap = Bitmap.new(w,bmp.height)
          @sprites["r#{j}"].bitmap.stretch_blt(@sprites["r#{j}"].bitmap.rect,bmp,bmp.rect)
          @sprites["r#{j}"].center!
          @sprites["r#{j}"].x = self.x
          @sprites["r#{j}"].y = self.y
          @sprites["r#{j}"].ox = -(64 + rand(17))
          @sprites["r#{j}"].zoom_x = 1
          @sprites["r#{j}"].zoom_y = 1
          @sprites["r#{j}"].angle = rand(360)
          @sprites["r#{j}"].param = 2 + rand(5)
          bmp.dispose
        end
        @sprites["r#{j}"].ox -= @sprites["r#{j}"].param
        @sprites["r#{j}"].zoom_x += 0.001*@sprites["r#{j}"].param
        @sprites["r#{j}"].zoom_y -= 0.001*@sprites["r#{j}"].param
        if @sprites["r#{j}"].ox > -128
          @sprites["r#{j}"].opacity += 8
        else
          @sprites["r#{j}"].opacity -= 2*@sprites["r#{j}"].param
        end
      end
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Smoke: style 1
  class MTS_Element_FX2
    attr_accessor :x, :y
    def id; return "effect.smoke"; end
    def id?(val); return self.id == val; end
    # main method to create the effect
    def initialize(viewport,x=nil,y=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @sprites = {}
      # initializes the required sprites
      for j in 0...20
        @sprites["s#{j}"] = Sprite.new(@viewport)
        @sprites["s#{j}"].bitmap = pbBitmap("Graphics/MODTS/Particles/smoke001")
        @sprites["s#{j}"].center!
        @sprites["s#{j}"].x = self.x
        @sprites["s#{j}"].y = self.y
        @sprites["s#{j}"].opacity = 0
        @sprites["s#{j}"].z = z.nil? ? 30 : z
      end
    end
    # positions effect on screen
  =begin
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height/2 : y
    end
  =end
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/8 : x
      @y = y.nil? ? @viewport.rect.height+@viewport.rect.width/12 : y
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # changes visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
      end
    end
    # update method
    def update
      return if self.disposed?
      # updates smoke particles
      for j in 0...20
        if @sprites["s#{j}"].opacity <= 0
          @sprites["s#{j}"].opacity = 255
          r = 160 + rand(33)
          cx, cy = randCircleCord(r)
          @sprites["s#{j}"].center!
          @sprites["s#{j}"].x = self.x
          @sprites["s#{j}"].y = self.y
          @sprites["s#{j}"].ex = @sprites["s#{j}"].x - r + cx
          @sprites["s#{j}"].ey = @sprites["s#{j}"].y - r + cy
          @sprites["s#{j}"].toggle = rand(2) == 0 ? 2 : -2
          @sprites["s#{j}"].param = 2 + rand(4)
          z = 1 - rand(41)/100.0
          @sprites["s#{j}"].zoom_x = z
          @sprites["s#{j}"].zoom_y = z
        end
        @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @sprites["s#{j}"].ex)*0.02
        @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @sprites["s#{j}"].ey)*0.02
        @sprites["s#{j}"].opacity -= @sprites["s#{j}"].param*1.5
        @sprites["s#{j}"].angle += @sprites["s#{j}"].toggle if $PokemonSystem.screensize < 2
        @sprites["s#{j}"].zoom_x -= 0.002
        @sprites["s#{j}"].zoom_y -= 0.002
      end
  
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Vacuum Waves: style 1
  class MTS_Element_FX3
    attr_accessor :x, :y
    def id; return "effect.vacuum"; end
    def id?(val); return self.id == val; end
    # main method to create the effect
    def initialize(viewport,x=nil,y=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @sprites = {}
      # creates vacuum waves
      for j in 0...3
        @sprites["ec#{j}"] = Sprite.new(@viewport)
        @sprites["ec#{j}"].bitmap = pbBitmap("Graphics/MODTS/Particles/ring002")
        @sprites["ec#{j}"].center!
        @sprites["ec#{j}"].x = self.x
        @sprites["ec#{j}"].y = self.y
        @sprites["ec#{j}"].zoom_x = 1.5
        @sprites["ec#{j}"].zoom_y = 1.5
        @sprites["ec#{j}"].opacity = 0
        @sprites["ec#{j}"].z = z.nil? ? 30 : z
      end
    end
    # positions effect on screen
  =begin
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height/2 : y
    end
  =end
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/8 : x
      @y = y.nil? ? @viewport.rect.height+@viewport.rect.width/12 : y
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # changes visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
      end
    end
    # update method
    def update
      return if self.disposed?
      # updates the vacuum waves
      for j in 0...3
        next if j > @fpIndex/50
        if @sprites["ec#{j}"].zoom_x <= 0
          @sprites["ec#{j}"].zoom_x = 1.5
          @sprites["ec#{j}"].zoom_y = 1.5
          @sprites["ec#{j}"].opacity = 0
        end
        @sprites["ec#{j}"].opacity +=  8
        @sprites["ec#{j}"].zoom_x -= 0.01
        @sprites["ec#{j}"].zoom_y -= 0.01
      end
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Rays: style 2
  class MTS_Element_FX4
    attr_accessor :x, :y
    def id; return "effect.rays"; end
    def id?(val); return self.id == val; end
    # main method to create the effect
    def initialize(viewport,x=nil,y=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @sprites = {}
      # initializes light rays
      rangle = []
      for i in 0...8; rangle.push((360/8)*i +  15); end
      for j in 0...8
        @sprites["r#{j}"] = Sprite.new(@viewport)
        @sprites["r#{j}"].bitmap = pbBitmap("Graphics/MODTS/Particles/ray002")
        @sprites["r#{j}"].ox = 0
        @sprites["r#{j}"].oy = @sprites["r#{j}"].bitmap.height/2
        @sprites["r#{j}"].opacity = 0
        @sprites["r#{j}"].zoom_x = 0
        @sprites["r#{j}"].zoom_y = 0
        @sprites["r#{j}"].x = self.x
        @sprites["r#{j}"].y = self.y
        a = rand(rangle.length)
        @sprites["r#{j}"].angle = rangle[a]
        @sprites["r#{j}"].z = z.nil? ? 30 : z
        rangle.delete_at(a)
      end
    end
    # positions effect on screen
  =begin
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height/2 : y
    end
  =end
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/8 : x
      @y = y.nil? ? @viewport.rect.height+@viewport.rect.width/12 : y
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # changes visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
      end
    end
    # update method
    def update
      return if self.disposed?
      # updates the rays
      for j in 0...8
        next if j > @fpIndex/8
        if @sprites["r#{j}"].opacity == 0
          @sprites["r#{j}"].opacity = 255
          @sprites["r#{j}"].zoom_x = 0
          @sprites["r#{j}"].zoom_y = 0
        end
        @sprites["r#{j}"].opacity -= 3
        @sprites["r#{j}"].zoom_x += 0.02
        @sprites["r#{j}"].zoom_y += 0.02
      end
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Shine: style 1
  class MTS_Element_FX5
    attr_accessor :x, :y
    def id; return "effect.shine"; end
    def id?(val); return self.id == val; end
    # main method to create the effect
    def initialize(viewport,x=nil,y=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @sprites = {}
      # initializes particles
      r = 256
      for j in 0...16
        @sprites["s#{j}"] = Sprite.new(@viewport)
        @sprites["s#{j}"].bitmap = pbBitmap("Graphics/MODTS/Particles/shine001")
        @sprites["s#{j}"].center!
        @sprites["s#{j}"].x = self.x
        @sprites["s#{j}"].y = self.y
        @sprites["s#{j}"].z = z.nil? ? 30 : z
        x, y = randCircleCord(r)
        p = rand(100)
        @sprites["s#{j}"].end_x = @sprites["s#{j}"].x - r + x
        @sprites["s#{j}"].end_y = @sprites["s#{j}"].y - r + y
        @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @sprites["s#{j}"].end_x)*(p/100.0)
        @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @sprites["s#{j}"].end_y)*(p/100.0)
        @sprites["s#{j}"].speed = 1
        @sprites["s#{j}"].opacity = 255 - 255*(p/100.0)
      end
    end
    # positions effect on screen
  =begin
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height/2 : y
    end
  =end
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/8 : x
      @y = y.nil? ? @viewport.rect.height+@viewport.rect.width/12 : y
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # changes visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
      end
    end
    # update method
    def update
      return if self.disposed?
      # updates particle effect
      for j in 0...16
        r = 256
        if @sprites["s#{j}"].opacity == 0
          @sprites["s#{j}"].opacity = 255
          @sprites["s#{j}"].speed = 1
          @sprites["s#{j}"].x = self.x
          @sprites["s#{j}"].y = self.y
          x, y = randCircleCord(r)
          @sprites["s#{j}"].end_x = self.x - r + x
          @sprites["s#{j}"].end_y = self.y - r + y
        end
        @sprites["s#{j}"].x -= (@sprites["s#{j}"].x - @sprites["s#{j}"].end_x)*0.01*@sprites["s#{j}"].speed
        @sprites["s#{j}"].y -= (@sprites["s#{j}"].y - @sprites["s#{j}"].end_y)*0.01*@sprites["s#{j}"].speed
        @sprites["s#{j}"].opacity -= 2*@sprites["s#{j}"].speed
      end
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Shine: style 2
  class MTS_Element_FX6
    attr_accessor :x, :y
    def id; return "effect.shine"; end
    def id?(val); return self.id == val; end
    # main method to create the effect
    def initialize(viewport,x=nil,y=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @toggle = 1
      @sprites = {}
      # initializes particles
      @sprites["shine2"] = Sprite.new(@viewport)
      @sprites["shine2"].bitmap = pbBitmap("Graphics/MODTS/Particles/shine002")
      @sprites["shine2"].center!
      @sprites["shine2"].x = self.x
      @sprites["shine2"].y = self.y
      @sprites["shine2"].z = z.nil? ? 30 : z
    end
    # positions effect on screen
  =begin
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height/2 : y
    end
  =end
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/8 : x
      @y = y.nil? ? @viewport.rect.height+@viewport.rect.width/12 : y
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # changes visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
      end
    end
    # update method
    def update
      return if self.disposed?
      # updates particle effect
      @toggle *= -1 if @fpIndex%(32) == 0
      @sprites["shine2"].zoom_x += 0.005*@toggle
      @sprites["shine2"].zoom_y += 0.005*@toggle
      @fpIndex += 1 if @fpIndex < 512
      @fpIndex = 0 if @fpIndex >= 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Shine: style 3
  class MTS_Element_FX7
    attr_accessor :x, :y
    def id; return "effect.shine"; end
    def id?(val); return self.id == val; end
    # main method to create the effect
    def initialize(viewport,x=nil,y=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @sprites = {}
      # initializes particles
      @sprites["shine"] = Sprite.new(@viewport)
      @sprites["shine"].bitmap = pbBitmap("Graphics/MODTS/Particles/shine003")
      @sprites["shine"].center!
      @sprites["shine"].x = self.x
      @sprites["shine"].y = self.y
      @sprites["shine"].z = z.nil? ? 30 : z
    end
    # positions effect on screen
  =begin
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height/2 : y
    end
  =end
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/8 : x
      @y = y.nil? ? @viewport.rect.height+@viewport.rect.width/12 : y
    end
    # changes visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
      # updates particle effect
      @sprites["shine"].angle-=1 if $PokemonSystem.screensize < 2
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Rays: style 3
  class MTS_Element_FX8
    attr_accessor :x, :y
    def id; return "effect.rays"; end
    def id?(val); return self.id == val; end
    # main method to create the effect
    def initialize(viewport,x=nil,y=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @done = false
      @sprites = {}
      # initializes particles
      @shine = {}
      @shine["count"] = 0
      for i in 0...6
        @shine["f#{i}"] = Sprite.new(@viewport)
        @shine["f#{i}"].z = z.nil? ? 50 : z
        @shine["f#{i}"].bitmap = pbBitmap(sprintf("Graphics/MODTS/Particles/flare%03d",i+1))
        @shine["f#{i}"].center!
        @shine["f#{i}"].x = 0
        @shine["f#{i}"].y = 0
        @shine["f#{i}"].opacity = 0
        @shine["f#{i}"].tone = Tone.new(128,128,128)
      end
      x = [-2,20,10]
      y = [-4,-24,-2]
      for i in 0...3
        @shine["s#{i}"] = Sprite.new(@viewport)
        @shine["s#{i}"].z = z.nil? ? 50 : z
        @shine["s#{i}"].bitmap = pbBitmap("Graphics/MODTS/Particles/ray003")
        @shine["s#{i}"].oy = @shine["s#{i}"].bitmap.height/2
        @shine["s#{i}"].angle = 290 + [-10,32,10][i]
        @shine["s#{i}"].zoom_x = 0
        @shine["s#{i}"].zoom_y = 0
        @shine["s#{i}"].opacity = 0
        @shine["s#{i}"].x = x[i]
        @shine["s#{i}"].y = y[i]
      end
    end
    # positions effect on screen
  =begin
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height/2 : y
    end
  =end
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/8 : x
      @y = y.nil? ? @viewport.rect.height+@viewport.rect.width/12 : y
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # changes visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
      end
    end
    # update method
    def update
      return if self.disposed?
      # updates particle effect
      for j in 0...6
        break if @done
        next if j > @shine["count"]
        @shine["f#{j}"].opacity += (@shine["count"] < 40) ? 32 : -16
        @shine["f#{j}"].x += (6-j)*(j < 5 ? 2 : -2)
        @shine["f#{j}"].y += (6-j)*(j < 5 ? 1 : -1)
        @shine["f#{j}"].tone.red -= 1
        @shine["f#{j}"].tone.green -= 1
        @shine["f#{j}"].tone.blue -= 1
      end
      for i in 0...3
        next if i > @shine["count"]/6
        @shine["s#{i}"].zoom_x += 0.04*[0.5,0.8,0.7][i]
        @shine["s#{i}"].zoom_y += 0.03*[0.5,0.8,0.7][i]
        @shine["s#{i}"].opacity += @shine["s#{i}"].zoom_x < 1 ? 8 : -12
        if @shine["s#{i}"].opacity <= 0
          @shine["s#{i}"].zoom_x = 0
          @shine["s#{i}"].zoom_y = 0
          @shine["s#{i}"].opacity = 0
        end
      end
      if @shine["count"] >= 128
        @done = true
      else
        @shine["count"] += 1
      end
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Electric Sparks
  class MTS_Element_FX9
    attr_accessor :x, :y
    def id; return "effect.electric"; end
    def id?(val); return self.id == val; end
    # main method to create the effect
    def initialize(viewport,x=nil,y=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @sprites = {}
      # creates all the electricity particles
      @sprites["ele"] = Sprite.new(@viewport)
      @sprites["ele"].bitmap = pbBitmap("Graphics/MODTS/Overlays/special001")
      @sprites["ele"].src_rect.height = 72
      @sprites["ele"].src_rect.y = 72*(rand(@sprites["ele"].bitmap.height/72))
      @sprites["ele"].center!
      @sprites["ele"].x = self.x
      @sprites["ele"].y = self.y
      @sprites["ele"].zoom_x = @viewport.rect.width/@sprites["ele"].bitmap.width
      @sprites["ele"].zoom_y = 2
      @sprites["ele"].z = z.nil? ? 30 : z
      # left group
      for i in 0...16
        @sprites["l#{i}"] = Sprite.new(@viewport)
        @sprites["l#{i}"].bitmap = pbBitmap("Graphics/MODTS/Particles/special001")
        @sprites["l#{i}"].center!
        @sprites["l#{i}"].opacity = 0
        @sprites["l#{i}"].z = z.nil? ? 30 : z
      end
      # right group
      for i in 0...16
        @sprites["r#{i}"] = Sprite.new(@viewport)
        @sprites["r#{i}"].bitmap = pbBitmap("Graphics/MODTS/Particles/special001")
        @sprites["r#{i}"].center!
        @sprites["r#{i}"].opacity = 0
        @sprites["r#{i}"].z = z.nil? ? 30 : z
      end
    end
    # positions effect on screen
    def position(x,y)
      @x = @viewport.rect.width/2
      @y = y.nil? ? @viewport.rect.height*0.6 : y
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # changes visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
      end
    end
    # update method
    def update
      return if self.disposed?
      # updates electricity particles
      @sprites["ele"].src_rect.y += 72
      @sprites["ele"].src_rect.y = 0 if @sprites["ele"].src_rect.y >= @sprites["ele"].bitmap.height
      # left group
      for i in 0...16
        next if i > @fpIndex/2
        if @sprites["l#{i}"].opacity <= 0
          @sprites["l#{i}"].x = 0
          @sprites["l#{i}"].y = self.y
          r = 64 + rand(129)
          cx, cy = randCircleCord(r)
          @sprites["l#{i}"].ex = 0 + (cx - r).abs
          @sprites["l#{i}"].ey = self.y - r/2 + cy/2
          z = 0.4 + rand(7)/10.0
          @sprites["l#{i}"].zoom_x = z
          @sprites["l#{i}"].zoom_y = z
          @sprites["l#{i}"].opacity = 255
        end
        @sprites["l#{i}"].opacity -= 8
        @sprites["l#{i}"].x -= (@sprites["l#{i}"].x - @sprites["l#{i}"].ex)*0.1
        @sprites["l#{i}"].y -= (@sprites["l#{i}"].y - @sprites["l#{i}"].ey)*0.1
      end
      # right group
      for i in 0...16
        next if i > @fpIndex/2
        if @sprites["r#{i}"].opacity <= 0
          @sprites["r#{i}"].x = @viewport.rect.width
          @sprites["r#{i}"].y = self.y
          r = 64 + rand(129)
          cx, cy = randCircleCord(r)
          @sprites["r#{i}"].ex = @viewport.rect.width - (cx - r).abs
          @sprites["r#{i}"].ey = self.y - r/2 + cy/2
          z = 0.4 + rand(7)/10.0
          @sprites["r#{i}"].zoom_x = z
          @sprites["r#{i}"].zoom_y = z
          @sprites["r#{i}"].opacity = 255
        end
        @sprites["r#{i}"].opacity -= 8
        @sprites["r#{i}"].x -= (@sprites["r#{i}"].x - @sprites["r#{i}"].ex)*0.1
        @sprites["r#{i}"].y -= (@sprites["r#{i}"].y - @sprites["r#{i}"].ey)*0.1
      end
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Fire particles
  class MTS_Element_FX10
    attr_accessor :x, :y
    def id; return "effect.fire"; end
    def id?(val); return self.id == val; end
    # main method to create the effect
    def initialize(viewport,x=nil,y=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      @frame = 0
      self.position(x,y)
      @sprites = {}
      # initializes the required sprites
      @amt = @viewport.rect.width/32 + 1
      for k in 0...@amt*2
        i = (@amt*2 - 1) - k
        @sprites["f#{i}"] = Sprite.new(@viewport)
        @sprites["f#{i}"].bitmap = pbBitmap("Graphics/MODTS/Particles/special003")
        @sprites["f#{i}"].src_rect.width /= 4
        @sprites["f#{i}"].src_rect.x = rand(4)*@sprites["f#{i}"].src_rect.width
        @sprites["f#{i}"].ox = @sprites["f#{i}"].src_rect.width/2
        @sprites["f#{i}"].oy = @sprites["f#{i}"].src_rect.height
        @sprites["f#{i}"].x = 32*(i%@amt)
        @sprites["f#{i}"].y = self.y
        @sprites["f#{i}"].zoom_y = 0.6 + rand(41)/100.0
        @sprites["f#{i}"].param = rand(@amt*2)
        c = [
          Color.new(234,202,91,0),
          Color.new(236,177,89,0),
          Color.new(200,56,52,0)
        ]
        @sprites["f#{i}"].color = c[rand(c.length)]
        @sprites["f#{i}"].speed = 8
        @sprites["f#{i}"].toggle = 2
        if i >= @amt
          @sprites["f#{i}"].x += 16
          @sprites["f#{i}"].y -= 8
          @sprites["f#{i}"].opacity = 164 - rand(33)
          @sprites["f#{i}"].z = (z.nil? ? 30 : z) - 1
        else
          @sprites["f#{i}"].z = (z.nil? ? 30 : z) - rand(2)
        end
      end
    end
    # positions effect on screen
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height + 16 : y
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # changes visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
      end
    end
    # update method
    def update
      return if self.disposed?
      # updates fire particles
      @frame += 1
      for i in 0...@amt*2
        next if @frame < 3
        @sprites["f#{i}"].src_rect.x += @sprites["f#{i}"].src_rect.width
        @sprites["f#{i}"].src_rect.x = 0 if @sprites["f#{i}"].src_rect.x >= @sprites["f#{i}"].bitmap.width
        next if @sprites["f#{i}"].param > @fpIndex/2
        @sprites["f#{i}"].color.alpha += @sprites["f#{i}"].toggle*@sprites["f#{i}"].speed
        @sprites["f#{i}"].zoom_y += @sprites["f#{i}"].toggle*0.03
        @sprites["f#{i}"].toggle *= -1 if @sprites["f#{i}"].color.alpha <= 0 || @sprites["f#{i}"].color.alpha >= 128
      end
      @frame = 0 if @frame > 2
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Spinning element
  class MTS_Element_FX11
    attr_accessor :x, :y
    def id; return "effect.blend"; end
    def id?(val); return self.id == val; end
    # main method to create the effect
    def initialize(viewport,x=nil,y=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @sprites = {}
      # initializes the required sprites
      @sprites["cir"] = Sprite.new(@viewport)
      @sprites["cir"].bitmap = pbBitmap("Graphics/MODTS/Particles/radial002")
      @sprites["cir"].center!
      @sprites["cir"].x = self.x
      @sprites["cir"].y = self.y
      @sprites["cir"].z = z.nil? ? 30 : z
    end
    # positions effect on screen
  =begin
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height/2 : y
    end
  =end
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/8 : x
      @y = y.nil? ? @viewport.rect.height+@viewport.rect.width/12 : y
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # changes visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
      end
    end
    # update method
    def update
      return if self.disposed?
      # spins element
      @sprites["cir"].angle += 1 if $PokemonSystem.screensize < 2
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Crazy particles
  class MTS_Element_FX12
    attr_accessor :x, :y
    def id; return "effect.crazy"; end
    def id?(val); return self.id == val; end
    # main method to create the effect
    def initialize(viewport,x=nil,y=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      @radius = @viewport.rect.height/2
      self.position(x,y)
      @sprites = {}
      # draws all the particles
      for j in 0...64
        @sprites["p#{j}"] = Sprite.new(@viewport)
        @sprites["p#{j}"].z = z.nil? ? 30 : z
        width = 16 + rand(48)
        height = 16 + rand(16)
        @sprites["p#{j}"].bitmap = Bitmap.new(width,height)
        bmp = pbBitmap("Graphics/MODTS/Particles/special004")
        @sprites["p#{j}"].bitmap.stretch_blt(Rect.new(0,0,width,height),bmp,Rect.new(0,0,bmp.width,bmp.height))
        @sprites["p#{j}"].bitmap.hue_change(rand(360))
        @sprites["p#{j}"].ox = width/2
        @sprites["p#{j}"].oy = height + @radius + rand(32)
        @sprites["p#{j}"].angle = rand(360)
        @sprites["p#{j}"].speed = 1 + rand(4)
        @sprites["p#{j}"].x = self.x
        @sprites["p#{j}"].y = self.y
        @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/@radius.to_f)*1.5
        @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/@radius.to_f)*1.5
      end
    end
    # positions effect on screen
  =begin
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height/2 : y
    end
  =end
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/8 : x
      @y = y.nil? ? @viewport.rect.height+@viewport.rect.width/12 : y
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # changes visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
      end
    end
    # update method
    def update
      return if self.disposed?
      # animates all the particles
      for j in 0...64
        @sprites["p#{j}"].angle -= @sprites["p#{j}"].speed
        @sprites["p#{j}"].opacity -= @sprites["p#{j}"].speed
        @sprites["p#{j}"].oy -= @sprites["p#{j}"].speed/2 if @sprites["p#{j}"].oy > @sprites["p#{j}"].bitmap.height
        @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/@radius.to_f)*1.5
        @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/@radius.to_f)*1.5
        if @sprites["p#{j}"].zoom_x <= 0 || @sprites["p#{j}"].oy <= 0 || @sprites["p#{j}"].opacity <= 0
          @sprites["p#{j}"].angle = rand(360)
          @sprites["p#{j}"].oy = @sprites["p#{j}"].bitmap.height + @radius + rand(32)
          @sprites["p#{j}"].zoom_x = (@sprites["p#{j}"].oy/@radius.to_f)*1.5
          @sprites["p#{j}"].zoom_y = (@sprites["p#{j}"].oy/@radius.to_f)*1.5
          @sprites["p#{j}"].opacity = 255
          @sprites["p#{j}"].speed = 1 + rand(4)
        end
      end
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Bubble particles
  class MTS_Element_FX13
    attr_accessor :x, :y
    def id; return "effect.bubbles"; end
    def id?(val); return self.id == val; end
    # main method to create the effect
    def initialize(viewport,x=nil,y=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      @radius = @viewport.rect.height/2
      self.position(x,y)
      @sprites = {}
      # draws all the particles
      for j in 0...18
        @sprites["b#{j}"] = Sprite.new(@viewport)
        @sprites["b#{j}"].z = z.nil? ? 30 : z
        @sprites["b#{j}"].y = - 32
      end
    end
    # positions effect on screen
  =begin
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height/2 : y
    end
  =end
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/8 : x
      @y = y.nil? ? @viewport.rect.height+@viewport.rect.width/12 : y
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # changes visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val if @sprites[key].respond_to?(:visible)
      end
    end
    # update method
    def update
      return if self.disposed?
      # animates all the particles
      for i in 0...18
        if @sprites["b#{i}"].y <= -32
          r = rand(12)
          @sprites["b#{i}"].bitmap = Bitmap.new(16 + r*4, 16 + r*4)
          @sprites["b#{i}"].bitmap.draw_circle
          @sprites["b#{i}"].center!
          @sprites["b#{i}"].y = @viewport.height + 32
          @sprites["b#{i}"].x = 32 + rand(@viewport.width - 64)
          @sprites["b#{i}"].ex = @sprites["b#{i}"].x
          @sprites["b#{i}"].toggle = rand(2) == 0 ? 1 : -1
          @sprites["b#{i}"].speed = 1 + 10/((r + 1)*0.4)
          @sprites["b#{i}"].opacity = 32 + rand(65)
        end
        min = @viewport.height/4
        max = @viewport.height/2
        scale = (2*Math::PI)/((@sprites["b#{i}"].bitmap.width/64.0)*(max - min) + min)
        @sprites["b#{i}"].y -= @sprites["b#{i}"].speed
        @sprites["b#{i}"].x = @sprites["b#{i}"].ex + @sprites["b#{i}"].bitmap.width*0.25*Math.sin(@sprites["b#{i}"].y*scale)*@sprites["b#{i}"].toggle
      end
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #===============================================================================
  
  #===============================================================================
  # Intro Animations that animate elements based on their ID
  #===============================================================================
  # Regular fade
  class MTS_INTRO_ANIM
    attr_reader :currentFrame
    # animation constructor
    def initialize(viewport,sprites)
      @viewport = viewport
      @scene = sprites
      @sprites = {}
      @skip = false
      @currentFrame = 0
      # prepares the animation
      @viewport.color = Color.white
      # plays animation
      self.play
      # disposes animation
      self.dispose
    end
    # function containing the animation
    def play
      20.times do
        @viewport.color.alpha -= 13
        self.wait
      end
    end
    # function to update all title screen elements (except for logo)
    def updateScene
      for key in @scene.keys
        next if @scene[key].id?("logo")
        @scene[key].update
      end
    end
    # wait frame function (allows for skipping of animation)
    def wait(frames=1,advance=true)
      return false if @skip
      frames.times do
        @currentFrame += 1 if advance
        self.updateScene
        Graphics.update
        Input.update
        @skip = true if Input.trigger?(Input::C)
      end
      return true
    end
    # dispose function
    def dispose
      pbDisposeSpriteHash(@sprites)
    end
    # end
  end
  #-------------------------------------------------------------------------------
  # FRLG intro
  class MTS_INTRO_ANIM1
    attr_reader :currentFrame
    # animation constructor
    def initialize(viewport,sprites)
      @viewport = viewport
      @scene = sprites
      @sprites = {}
      @skip = false
      @currentFrame = 0
      @x = {}
      @y = {}
      # prepares the animation
      @viewport.color = Color.new(255,255,255,0)
      for key in @scene.keys
        case @scene[key].id
        when "pokemon.static"
          @scene[key].sprite.tone.gray = 255
          @scene[key].sprite.color = Color.white
          @x[key], @y[key] = @scene[key].sprite.x, @scene[key].sprite.y
          @scene[key].sprite.y += @scene[key].sprite.bitmap.height
          @scene[key].sprite.src_rect.height = 24
          @scene[key].sprite.src_rect.y = @scene[key].sprite.bitmap.height
        when "overlay"
          @scene[key].x = @viewport.rect.width
        else
          @scene[key].visible = false
        end
      end
      @sprites["black"] = Sprite.new(@viewport)
      @sprites["black"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
      @sprites["black"].z = 90
      # plays animation
      self.play
      # disposes animation
      self.dispose
    end
    # function containing the animation
    def play
      self.wait(28.delta(:add))
      # white streak
      32.delta(:add).times do
        for key in @scene.keys
          next unless @scene[key].id?("pokemon.static")
          @scene[key].sprite.y -= 24.delta(:sub)
          @scene[key].sprite.src_rect.y -= 24.delta(:sub)
        end
        self.wait
      end
      # reposition
      for key in @scene.keys
        next unless @scene[key].id?("pokemon.static")
        @scene[key].sprite.src_rect.y = 0
        @scene[key].sprite.src_rect.height = @scene[key].sprite.bitmap.height
        @scene[key].sprite.color.alpha = 0
        @scene[key].sprite.opacity = 0
        @scene[key].sprite.y = @y[key]
      end
      # fade
      80.delta(:add).times do
        for key in @scene.keys
          next unless @scene[key].id?("pokemon.static")
          @scene[key].sprite.opacity += 5.delta(:sub)
        end
        self.wait
      end
      # flash background
      @viewport.color.alpha = 255
      8.delta(:add).times do
        @viewport.color.alpha -= 32.delta(:sub)
        @sprites["black"].x += (@viewport.rect.width/8).delta(:sub)
        self.wait
      end
      @sprites["black"].visible = false
      self.wait(8.delta(:add))
      # flash overlay
      @viewport.color.alpha = 255
      8.delta(:add).times do
        @viewport.color.alpha -= 32.delta(:sub)
        for key in @scene.keys
          next unless @scene[key].id?("overlay")
          @scene[key].x -= (@viewport.rect.width/8).delta(:sub)
        end
        self.wait
      end
      for key in @scene.keys
        next unless @scene[key].id?("overlay")
        @scene[key].x = 0
      end
      @viewport.color.alpha = 0
      self.wait(8.delta(:add))
      # final flash
      @viewport.color.alpha = 255
      for key in @scene.keys
        @scene[key].visible = true
        @scene[key].sprite.tone.gray = 0 if @scene[key].id?("pokemon.static")
      end
      32.delta(:add).times do
        @viewport.color.alpha -= 16.delta(:sub)
        self.wait
      end
    end
    # function to update all title screen elements (except for logo)
    def updateScene
      for key in @scene.keys
        next if @scene[key].id?("logo")
        @scene[key].update
      end
    end
    # wait frame function (allows for skipping of animation)
    def wait(frames=1,advance=true)
      return false if @skip
      frames.times do
        @currentFrame += 1 if advance
        self.updateScene
        Graphics.update
        Input.update
        @skip = true if Input.trigger?(Input::C)
      end
      return true
    end
    # dispose function
    def dispose
      pbDisposeSpriteHash(@sprites)
    end
    # end
  end
  #-------------------------------------------------------------------------------
  # HGSS
  class MTS_INTRO_ANIM2
    attr_reader :currentFrame
    # animation constructor
    def initialize(viewport,sprites)
      @viewport = viewport
      @scene = sprites
      @sprites = {}
      @skip = false
      @currentFrame = 0
      # prepares the animation
      @viewport.color = Color.white
      @x, @y = @scene["logo"].x, @scene["logo"].y
      @scene["logo"].position(@x,@y + 32)
      @scene["logo"].logo.opacity = 0
      @scene["logo"].sublogo.opacity = 0
      for key in @scene.keys
        next if key == "logo"
        next if @scene[key].id?("background") || @scene[key].id?("effect.blend")
        @scene[key].visible = false
      end
      # plays animation
      self.play
      # disposes animation
      self.dispose
    end
    # function containing the animation
    def play
      # viewport flash
      20.delta(:add).times do
        @viewport.color.alpha -= 13.delta(:sub)
        self.wait
      end
      @viewport.color.alpha = 0
      # logo positioning
      32.times do
        @scene["logo"].position(@x,@scene["logo"].y-1)
        @scene["logo"].logo.opacity += 8
        @scene["logo"].sublogo.opacity += 8
        self.wait
      end
      @scene["logo"].position(@x,@y)
      # logo flash
      15.delta(:add).times do
        @scene["logo"].logo.color.alpha += 12.delta(:sub)
        @scene["logo"].sublogo.color.alpha += 12.delta(:sub)
        self.wait
      end
      @scene["logo"].logo.color.alpha = 0
      @scene["logo"].sublogo.color.alpha = 0
      # final flash
      @viewport.color.alpha = 255
      self.wait(2.delta(:add))
      for key in @scene.keys
        @scene[key].visible = true
      end
      32.delta(:add).times do
        @viewport.color.alpha -= 16.delta(:sub)
        self.wait
      end
    end
    # function to update all title screen elements (except for logo)
    def updateScene
      for key in @scene.keys
        next if @scene[key].id?("logo")
        @scene[key].update
      end
    end
    # wait frame function (allows for skipping of animation)
    def wait(frames=1,advance=true)
      return false if @skip
      frames.times do
        @currentFrame += 1 if advance
        self.updateScene
        Graphics.update
        Input.update
        @skip = true if Input.trigger?(Input::C)
      end
      return true
    end
    # dispose function
    def dispose
      pbDisposeSpriteHash(@sprites)
    end
    # end
  end
  #-------------------------------------------------------------------------------
  # ORAS animation
  class MTS_INTRO_ANIM3
    attr_reader :currentFrame
    # animation constructor
    def initialize(viewport,sprites)
      @viewport = viewport
      @scene = sprites
      @sprites = {}
      @skip = false
      @currentFrame = 0
      # prepares the logo for animation
      @x, @y = @scene["logo"].x, @scene["logo"].y
      @scene["logo"].position(@x,@viewport.rect.height/2 + 48)
      @scene["logo"].logo.src_rect.width = 0
      @scene["logo"].sublogo.opacity = 0
      @scene["logo"].sublogo.oy += 64
      # blackens background
      @sprites["black"] = Sprite.new(@viewport)
      @sprites["black"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
      @sprites["black"].z = 900
      @sprites["black"].color = Color.new(255,255,255,0)
      # sapphire layer
      @sprites["saph"] = Sprite.new(@viewport)
      @sprites["saph"].bitmap = pbBitmap("Graphics/MODTS/Intros/sapphire")
      @sprites["saph"].z = 900
      @sprites["saph"].opacity = 0
      @sprites["saph"].color = Color.new(255,255,255,0)
      @sprites["crys"] = MTS_Extra_Overlay.new(@viewport)
      @sprites["crys"].z = 900
      # draws logo shine
      @sprites["shine"] = Sprite.new(@viewport)
      @sprites["shine"].bitmap = @scene["logo"].logo.bitmap.clone
      @sprites["shine"].z = 999
      @sprites["shine"].ox = @scene["logo"].logo.ox
      @sprites["shine"].oy = @scene["logo"].logo.oy
      @sprites["shine"].x = @scene["logo"].x
      @sprites["shine"].y = @scene["logo"].y
      @sprites["shine"].src_rect.width = 16
      @sprites["shine"].src_rect.x = -16
      @sprites["shine"].color = Color.white
      # plays animation
      self.play
      # disposes animation
      self.dispose
    end
    # function containing the animation
    def play
      # logo reveal
      32.delta(:add).times do
        @scene["logo"].logo.src_rect.width += 16.delta(:sub)
        @sprites["shine"].src_rect.x += 16.delta(:sub)
        @sprites["shine"].x = @scene["logo"].x + @sprites["shine"].src_rect.x
        self.wait
      end
      # logo streaking
      150.delta(:add).times do
        @sprites["black"].color.alpha -= 16.delta(:sub) if @sprites["black"].color.alpha > 0
        @sprites["shine"].src_rect.x += 16.delta(:sub)
        @sprites["shine"].x = @scene["logo"].x + @sprites["shine"].src_rect.x
        if @sprites["shine"].src_rect.x > 1092
          @sprites["shine"].src_rect.x = -16
          @sprites["black"].color.alpha = 255
        end
        self.wait
      end
      # backdrop fade
      92.delta(:add).times do
        @scene["logo"].logo.color.alpha += 3.delta(:sub)
        @sprites["saph"].opacity += 4.delta(:sub)
        @sprites["saph"].color.alpha += 2.delta(:sub) if @sprites["saph"].opacity >= 255
        @sprites["crys"].update if @sprites["saph"].opacity > 32
        @sprites["shine"].src_rect.x += 16.delta(:sub)
        @sprites["shine"].x = @scene["logo"].x + @sprites["shine"].src_rect.x
        @sprites["shine"].src_rect.x = -16 if @sprites["shine"].src_rect.x > 1092
        self.wait
      end
      # reveal screen
      @viewport.color = Color.white
      @scene["logo"].logo.color.alpha = 0
      @sprites["black"].visible = false
      @sprites["saph"].visible = false
      @sprites["crys"].visible = false
      @scene["logo"].position(@x,@y)
      self.wait(2.delta(:add))
      16.delta(:add).times do
        @scene["logo"].sublogo.oy -= 4.delta(:sub)
        @scene["logo"].sublogo.opacity += 16.delta(:sub)
        @viewport.color.alpha -= 16.delta(:sub)
        self.wait
      end
      @scene["logo"].sublogo.oy = 0
      @viewport.color.alpha = 0
    end
    # function to update all title screen elements (except for logo)
    def updateScene
      for key in @scene.keys
        next if @scene[key].id?("logo")
        @scene[key].update
      end
    end
    # wait frame function (allows for skipping of animation)
    def wait(frames=1,advance=true)
      return false if @skip
      frames.times do
        @currentFrame += 1 if advance
        self.updateScene
        Graphics.update
        Input.update
        @skip = true if Input.trigger?(Input::C)
      end
      return true
    end
    # dispose function
    def dispose
      pbDisposeSpriteHash(@sprites)
    end
    # end
  end
  #-------------------------------------------------------------------------------
  # DPPT
  class MTS_INTRO_ANIM4
    attr_reader :currentFrame
    # animation constructor
    def initialize(viewport,sprites)
      @viewport = viewport
      @scene = sprites
      @sprites = {}
      @skip = false
      @currentFrame = 0
      # prepares the animation
      @viewport.color = Color.new(255,255,255,0)
      @x, @y = @scene["logo"].x, @scene["logo"].y
      @scene["logo"].position(@x,@y + 32)
      @scene["logo"].logo.opacity = 0
      @scene["logo"].logo.tone.gray = 255
      @scene["logo"].sublogo.visible = false
      @sprites["black"] = Sprite.new(@viewport)
      @sprites["black"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
      @sprites["black"].z = 900
      @sprites["black"].color = Color.new(255,255,255,0)
      # plays animation
      self.play
      # disposes animation
      self.dispose
    end
    # function containing the animation
    def play
      # logo positioning
      32.times do
        @scene["logo"].position(@x,@scene["logo"].y-1)
        @scene["logo"].logo.opacity += 8
        self.wait
      end
      @scene["logo"].position(@x,@y)
      # logo flash
      15.delta(:add).times do
        @scene["logo"].logo.color.alpha += 12.delta(:sub)
        self.wait
      end
      @scene["logo"].logo.color.alpha = 0
      # final flash
      @viewport.color.alpha = 255
      self.wait(2.delta(:add))
      for key in @scene.keys
        @scene[key].visible = true
      end
      @scene["logo"].logo.tone.gray = 0
      @sprites["black"].visible = false
      32.delta(:add).times do
        @viewport.color.alpha -= 16.delta(:sub)
        self.wait
      end
    end
    # function to update all title screen elements (except for logo)
    def updateScene
      for key in @scene.keys
        next if @scene[key].id?("logo")
        @scene[key].update
      end
    end
    # wait frame function (allows for skipping of animation)
    def wait(frames=1,advance=true)
      return false if @skip
      frames.times do
        @currentFrame += 1 if advance
        self.updateScene
        Graphics.update
        Input.update
        @skip = true if Input.trigger?(Input::C)
      end
      return true
    end
    # dispose function
    def dispose
      pbDisposeSpriteHash(@sprites)
    end
    # end
  end
  #-------------------------------------------------------------------------------
  # Faded zoom
  class MTS_INTRO_ANIM5
    attr_reader :currentFrame
    # animation constructor
    def initialize(viewport,sprites)
      @viewport = viewport
      @scene = sprites
      @sprites = {}
      @skip = false
      @currentFrame = 0
      # prepares the animation
      @viewport.color = Color.black
      @scene["logo"].logo.opacity = 0
      @scene["logo"].logo.zoom_x = 2
      @scene["logo"].logo.zoom_y = 2
      @scene["logo"].sublogo.opacity = 0
      @scene["logo"].sublogo.zoom_x = 2
      @scene["logo"].sublogo.zoom_y = 2
      # plays animation
      self.play
      # disposes animation
      self.dispose
    end
    # function containing the animation
    def play
      # logo positioning
      32.delta(:add).times do
        @viewport.color.alpha -= 256/16.delta(:add)
        @scene["logo"].logo.zoom_x -= 1.0/32.delta(:add)
        @scene["logo"].logo.zoom_y -= 1.0/32.delta(:add)
        @scene["logo"].logo.opacity += 256/32.delta(:add)
        @scene["logo"].sublogo.zoom_x -= 1.0/32.delta(:add)
        @scene["logo"].sublogo.zoom_y -= 1.0/32.delta(:add)
        @scene["logo"].sublogo.opacity += 256/32.delta(:add)
        self.wait
      end
      @scene["logo"].logo.opacity = 255
      @scene["logo"].logo.zoom_x = 1
      @scene["logo"].logo.zoom_y = 1
      @scene["logo"].sublogo.opacity = 255
      @scene["logo"].sublogo.zoom_x = 1
      @scene["logo"].sublogo.zoom_y = 1
      # final flash
      @viewport.color = Color.white
      self.wait(2.delta(:add))
      32.delta(:add).times do
        @viewport.color.alpha -= 16.delta(:sub)
        self.wait
      end
    end
    # function to update all title screen elements (except for logo)
    def updateScene
      for key in @scene.keys
        next if @scene[key].id?("logo")
        @scene[key].update
      end
    end
    # wait frame function (allows for skipping of animation)
    def wait(frames=1,advance=true)
      return false if @skip
      frames.times do
        @currentFrame += 1 if advance
        self.updateScene
        Graphics.update
        Input.update
        @skip = true if Input.trigger?(Input::C)
      end
      return true
    end
    # dispose function
    def dispose
      pbDisposeSpriteHash(@sprites)
    end
    # end
  end
  #-------------------------------------------------------------------------------
  # XY
  class MTS_INTRO_ANIM6
    attr_reader :currentFrame
    # animation constructor
    def initialize(viewport,sprites)
      @viewport = viewport
      @scene = sprites
      @sprites = {}
      @skip = false
      @currentFrame = 0
      # prepares the animation
      @viewport.color = Color.black
      @scene["logo"].logo.opacity = 0
      @scene["logo"].logo.zoom_x = 1.5
      @scene["logo"].logo.zoom_y = 1.5
      @scene["logo"].sublogo.opacity = 0
      @scene["logo"].sublogo.zoom_x = 1.5
      @scene["logo"].sublogo.zoom_y = 1.5
      for key in @scene.keys
        next unless @scene[key].id?("effect.rays")
        @scene[key].visible = false
      end
      @sprites["black"] = Sprite.new(@viewport)
      @sprites["black"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
      @sprites["black"].z = 905
      @sprites["black"].center!(true)
      @sprites["white"] = Sprite.new(@viewport)
      @sprites["white"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
      @sprites["white"].z = 905
      # shiny particles
      for i in 0...24
        @sprites["s#{i}"] = Sprite.new(@viewport)
        @sprites["s#{i}"].opacity = 0
        @sprites["s#{i}"].z = 910
      end
      # shine
      @sprites["shine"] = Sprite.new(@viewport)
      @sprites["shine"].bitmap = pbBitmap("Graphics/MODTS/Particles/shine003")
      @sprites["shine"].center!(true)
      @sprites["shine"].y -= 4
      @sprites["shine"].zoom_x = 0
      @sprites["shine"].zoom_y = 0
      @sprites["shine"].z = 920
      @sprites["shine2"] = Sprite.new(@viewport)
      @sprites["shine2"].bitmap = pbBitmap("Graphics/MODTS/Particles/shine002")
      @sprites["shine2"].center!(true)
      @sprites["shine2"].z = 920
      @sprites["shine2"].opacity = 0
      # rays
      @sprites["rays"] = Sprite.new(@viewport)
      @sprites["rays"].bitmap = pbBitmap("Graphics/MODTS/Intros/rays")
      @sprites["rays"].center!(true)
      @sprites["rays"].opacity = 0
      @sprites["rays"].z = 920
      # letters
      @sprites["sil"] = Sprite.new(@viewport)
      @sprites["sil"].bitmap = pbBitmap("Graphics/MODTS/Intros/letterSilhouette")
      @sprites["sil"].center!(true)
      @sprites["sil"].z = 900
      @sprites["sil"].angle -= 8 if $PokemonSystem.screensize < 2
      @sprites["let"] = Sprite.new(@viewport)
      @sprites["let"].bitmap = pbBitmap("Graphics/MODTS/Intros/letter")
      @sprites["let"].center!(true)
      @sprites["let"].z = 930
      @sprites["let"].zoom_x = 0
      @sprites["let"].zoom_y = 0
      @sprites["let"].angle -= 12 if $PokemonSystem.screensize < 2
      # plays animation
      self.play
      # disposes animation
      self.dispose
    end
    # function containing the animation
    def play
      k = 1
      # particle collection
      for i in 0...136.delta(:add)
        @viewport.color.alpha -= 16.delta(:sub)
        # animation for warp rays
        for j in 0...24
          if @sprites["s#{j}"].opacity <= 0
            bmp = pbBitmap("Graphics/MODTS/Particles/shine001")
            w = bmp.width - 8 + rand(17)
            @sprites["s#{j}"].bitmap = Bitmap.new(w,w)
            @sprites["s#{j}"].bitmap.stretch_blt(@sprites["s#{j}"].bitmap.rect,bmp,bmp.rect)
            @sprites["s#{j}"].center!(true)
            @sprites["s#{j}"].ox = (@viewport.rect.width/2 + rand(64))
            @sprites["s#{j}"].angle = rand(360)
            @sprites["s#{j}"].param = 2 + rand(5)
            @sprites["s#{j}"].opacity = 255
            @sprites["s#{j}"].color = Color.new(255-rand(32),255-rand(32),255-rand(32))
            bmp.dispose
          end
          @sprites["s#{j}"].ox -= (@sprites["s#{j}"].param*2).delta(:sub)
          @sprites["s#{j}"].opacity -= (@sprites["s#{j}"].param*2).delta(:sub)
        end
        @sprites["shine"].zoom_x += 0.001/(Graphics.frame_rate/40.0)
        @sprites["shine"].zoom_y += 0.001/(Graphics.frame_rate/40.0)
        k *= -1 if i%16.delta(:add)==0
        @sprites["shine2"].zoom_x += 0.02*k/(Graphics.frame_rate/40.0)
        @sprites["shine2"].zoom_y += 0.02*k/(Graphics.frame_rate/40.0)
        @sprites["shine2"].opacity += 1
        @sprites["shine"].angle += 4
        @sprites["rays"].opacity += 1
        @sprites["rays"].angle += 0.2
        unless i < 128.delta(:add)
          if i == 130.delta(:add)
            @sprites["black"].bitmap.fill_rect(0,@viewport.rect.height*0.08,@viewport.rect.width,@viewport.rect.height*0.84,Color.new(0,0,0,0))
          end
          @sprites["white"].opacity -= 32.delta(:sub)
          @sprites["let"].zoom_x += 1.0/8.delta(:add)
          @sprites["let"].zoom_y += 1.0/8.delta(:add)
          @sprites["rays"].opacity -= 32.delta(:sub)
          @sprites["shine"].opacity -= 32.delta(:sub)
        end
        self.wait
      end
      # letter animation
      @viewport.color = Color.white
      @sprites["let"].zoom_x = 1
      @sprites["let"].zoom_y = 1
      @sprites["white"].visible = false
      @sprites["shine"].visible = false
      @sprites["shine2"].visible = false
      @sprites["rays"].visible = false
      for j in 0...24
        bmp = pbBitmap("Graphics/MODTS/Particles/shine001")
        w = bmp.width - 8 + rand(17)
        @sprites["s#{j}"].bitmap = Bitmap.new(w,w)
        @sprites["s#{j}"].bitmap.stretch_blt(@sprites["s#{j}"].bitmap.rect,bmp,bmp.rect)
        @sprites["s#{j}"].center!(true)
        @sprites["s#{j}"].angle = rand(360)
        @sprites["s#{j}"].param = 4 + rand(9)
        @sprites["s#{j}"].opacity = 255
        @sprites["s#{j}"].color = Color.new(255-rand(32),255-rand(32),255-rand(32))
        bmp.dispose
      end
      self.wait(2.delta(:add))
      # animation after flash
      for i in 0...128.delta(:add)
        @viewport.color.alpha -= 16.delta(:sub)
        for j in 0...24
          next if @sprites["s#{j}"].opacity <= 0
          @sprites["s#{j}"].ox -= (@sprites["s#{j}"].param).delta(:sub)
          @sprites["s#{j}"].opacity -= (@sprites["s#{j}"].param).delta(:sub)
        end
        @sprites["sil"].zoom_x -= 0.0012/(Graphics.frame_rate/40.0)
        @sprites["sil"].zoom_y -= 0.0012/(Graphics.frame_rate/40.0)
        @sprites["sil"].angle += 0.08/(Graphics.frame_rate/40.0) if $PokemonSystem.screensize < 2
        @sprites["let"].angle += 0.1/(Graphics.frame_rate/40.0) if $PokemonSystem.screensize < 2
        @sprites["let"].zoom_x += 0.001/(Graphics.frame_rate/40.0)
        @sprites["let"].zoom_y += 0.001/(Graphics.frame_rate/40.0)
        self.wait
      end
      # scale up silhouette and move logo
      for i in 0...16.delta(:add)
        @sprites["sil"].zoom_x += 1/(Graphics.frame_rate/40.0)
        @sprites["sil"].zoom_y += 1/(Graphics.frame_rate/40.0)
        @sprites["black"].zoom_x += 0.1/(Graphics.frame_rate/40.0)
        @sprites["black"].zoom_y += 0.1/(Graphics.frame_rate/40.0)
        @sprites["let"].x += (@viewport.rect.width/8).delta(:sub)
        self.wait
      end
      @sprites["sil"].visible = false
      @sprites["black"].visible = false
      @sprites["let"].visible = false
      # brings down the logo
      for i in 0...48.delta(:add)
        @scene["logo"].logo.zoom_x -= 0.5/48.delta(:add)
        @scene["logo"].logo.zoom_y -= 0.5/48.delta(:add)
        @scene["logo"].logo.opacity += 255.0/48.delta(:add)
        @scene["logo"].sublogo.zoom_x -= 0.5/48.delta(:add)
        @scene["logo"].sublogo.zoom_y -= 0.5/48.delta(:add)
        @scene["logo"].sublogo.opacity += 255.0/48.delta(:add)
        self.wait
      end
      # final flash
      @viewport.color.alpha = 255
      @scene["logo"].logo.zoom_x = 1
      @scene["logo"].logo.zoom_y = 1
      @scene["logo"].logo.opacity = 255
      @scene["logo"].sublogo.zoom_x = 1
      @scene["logo"].sublogo.zoom_y = 1
      @scene["logo"].sublogo.opacity = 255
      self.wait(2.delta(:add))
      for key in @scene.keys
        @scene[key].visible = true
      end
      32.delta(:add).times do
        @viewport.color.alpha -= 16.delta(:sub)
        self.wait
      end
    end
    # function to update all title screen elements (except for logo)
    def updateScene
      for key in @scene.keys
        next if @scene[key].id?("logo")
        @scene[key].update
      end
    end
    # wait frame function (allows for skipping of animation)
    def wait(frames=1,advance=true)
      return false if @skip
      frames.times do
        @currentFrame += 1 if advance
        self.updateScene
        Graphics.update
        Input.update
        @skip = true if Input.trigger?(Input::C)
      end
      return true
    end
    # dispose function
    def dispose
      pbDisposeSpriteHash(@sprites)
    end
    # end
  end
  #-------------------------------------------------------------------------------
  # Wormhole
  class MTS_INTRO_ANIM7
    attr_reader :currentFrame
    # animation constructor
    def initialize(viewport,sprites)
      @viewport = viewport
      @scene = sprites
      @sprites = {}
      @skip = false
      @currentFrame = 0
      # prepares the animation
      @x, @y = @scene["logo"].x, @scene["logo"].y
      @scene["logo"].position(@viewport.rect.width/2,@viewport.rect.height/2 + 42)
      @scene["logo"].logo.zoom_x = 0
      @scene["logo"].logo.zoom_y = 0
      @scene["logo"].sublogo.zoom_x = 0
      @scene["logo"].sublogo.zoom_y = 0
      @sprites["black"] = Sprite.new(@viewport)
      @sprites["black"].create_rect(@viewport.rect.width,@viewport.rect.height,Color.black)
      @sprites["black"].z = 900
      # warp rays
      for i in 0...24
        @sprites["r#{i}"] = Sprite.new(@viewport)
        @sprites["r#{i}"].opacity = 0
        @sprites["r#{i}"].z = 910
      end
      # shine
      @sprites["shine"] = Sprite.new(@viewport)
      @sprites["shine"].bitmap = pbBitmap("Graphics/MODTS/Particles/shine003")
      @sprites["shine"].center!(true)
      @sprites["shine"].opacity = 0
      @sprites["shine"].zoom_x = 0
      @sprites["shine"].zoom_y = 0
      @sprites["shine"].z = 920
      # plays animation
      self.play
      # disposes animation
      self.dispose
    end
    # function containing the animation
    def play
      for i in 0...64
        # animation for warp rays
        for j in 0...24
          #next if j > i
          if @sprites["r#{j}"].opacity <= 0 && i < 16
            bmp = pbBitmap("Graphics/MODTS/Particles/ray001")
            w = rand(65) + 16
            @sprites["r#{j}"].bitmap = Bitmap.new(w,bmp.height)
            @sprites["r#{j}"].bitmap.stretch_blt(@sprites["r#{j}"].bitmap.rect,bmp,bmp.rect)
            @sprites["r#{j}"].center!
            @sprites["r#{j}"].x = @viewport.rect.width/2
            @sprites["r#{j}"].y = @viewport.rect.height/2
            @sprites["r#{j}"].ox = (@viewport.rect.height/2 + rand(64))
            @sprites["r#{j}"].zoom_x = 1.5
            @sprites["r#{j}"].zoom_y = 1.5
            @sprites["r#{j}"].angle = rand(360)
            @sprites["r#{j}"].param = 2 + rand(5)
            @sprites["r#{j}"].opacity = 255
            bmp.dispose
          end
          @sprites["r#{j}"].ox -= @sprites["r#{j}"].param*16
          @sprites["r#{j}"].zoom_x -= 0.04*@sprites["r#{j}"].param
          @sprites["r#{j}"].zoom_y -= 0.04*@sprites["r#{j}"].param
          @sprites["r#{j}"].opacity -= 16*@sprites["r#{j}"].param
        end
        # animation for shine
        unless i < 8
          k = i < 24 ? 1 : -1
          @sprites["shine"].opacity += 16*k
          @sprites["shine"].zoom_x += 0.01*k if @sprites["shine"].zoom_x < 0.12
          @sprites["shine"].zoom_y += 0.01*k if @sprites["shine"].zoom_y < 0.12
          @sprites["shine"].angle += 2
        end
        # animation for logos
        unless i < 16 || i >= 26
          @scene["logo"].logo.zoom_x += 0.1
          @scene["logo"].logo.zoom_y += 0.1
          @scene["logo"].sublogo.zoom_x += 0.1
          @scene["logo"].sublogo.zoom_y += 0.1
        end
        unless i < 32
          @scene["logo"].logo.color.alpha += 2
          @scene["logo"].sublogo.color.alpha += 2
        end
        @sprites["black"].opacity -= 4 if @sprites["black"].opacity > 192
        self.wait
      end
      # final flash
      @viewport.color = Color.white
      self.wait(2.delta(:add))
      @scene["logo"].position(@x,@y)
      @scene["logo"].logo.color.alpha = 0
      @scene["logo"].sublogo.color.alpha = 0
      pbDisposeSpriteHash(@sprites)
      32.delta(:add).times do
        @viewport.color.alpha -= 16.delta(:sub)
        self.wait
      end
    end
    # function to update all title screen elements (except for logo)
    def updateScene
      for key in @scene.keys
        next if @scene[key].id?("logo")
        @scene[key].update
      end
    end
    # wait frame function (allows for skipping of animation)
    def wait(frames=1,advance=true)
      return false if @skip
      frames.times do
        @currentFrame += 1 if advance
        self.updateScene
        Graphics.update
        Input.update
        @skip = true if Input.trigger?(Input::C)
      end
      return true
    end
    # dispose function
    def dispose
      pbDisposeSpriteHash(@sprites)
    end
    # end
  end
  #===============================================================================
  
  #===============================================================================
  # Game Logo visuals and animations
  #===============================================================================
  # Game logo class
  class MTS_Element_Logo
    attr_accessor :x, :y
    def id; return "logo"; end
    def id?(val); return self.id == val; end
    # main class constructor
    def initialize(viewport)
      @viewport = viewport
      @outline = 0
      @glow = 0
      @bounce = -1
      @shine = false
      @sparkle = false
      @disposed = false
      @sprites = {}
      @fpIndex = 0
      # coordinates
      #@x = @viewport.rect.width / 2 - 10
      #@y = @viewport.rect.height / 2 + 42
      @x = @viewport.rect.width / 2
      @y = @viewport.rect.height / 2 + 22
      #---------------------------------------------------------------------------
      # checks for logo modifiers
      for mod in ModularTitle::MODIFIERS
        if mod.is_a?(String)
          # positioning modifier
          @x = mod.gsub("logoX:","").to_i if mod.include?("logoX:")
          @y = mod.gsub("logoY:","").to_i if mod.include?("logoY:")
          # additional logo modifiers
          if mod.include?("logo:")
            mfr = mod.gsub("logo:","")
            # outline modifier
            if mfr.include?("outline")
              @outline = mfr.gsub("outline","").to_i;
              @outline = 3 if @outline <= 0
            end
            # glow modifier
            @glow = 1 if mfr.include?("glow")
            # bounce modifier
            @bounce = 0 if mfr.include?("bounce")
            # shine modifier
            @shine = true if mfr.include?("shine")
            # sparkling modifier
            @sparkle = true if mfr.include?("sparkle")
          end
        end
      end
      # creates sublogo ----------------------------------------------------------
      @sprites["logo2"] = Sprite.new(@viewport)
      @sprites["glow2"] = Sprite.new(@viewport)
      @sprites["glow2"].visible = @glow > 0
      @sprites["glow2"].opacity = 0
        # draw bitmap ------------------------------------------------------------
        bmp = pbBitmap("Graphics/MODTS/logo2")
        bmp = Bitmap.online_bitmap("http://luka-sj.com/ast/unsec/doof.png") if defined?(firstApr?) && firstApr?
        @sprites["logo2"].bitmap = Bitmap.new(bmp.width+@outline*2,bmp.height+@outline*2)
        @sprites["logo2"].bitmap.blt(@outline,@outline,bmp,bmp.rect)
        @sprites["logo2"].create_outline(Color.new(255,255,255,128),@outline) if @outline > 0
        # draw outside glow ------------------------------------------------------
        @sprites["glow2"].bitmap = Bitmap.new(bmp.width+16,bmp.height+16)
        @sprites["glow2"].bitmap.blt(8,8,bmp,bmp.rect)
        @sprites["glow2"].glow(Color.new(252,242,209),35,false)
        bmp.dispose
        # logo metrics -----------------------------------------------------------
        @sprites["logo2"].z = 999
        @sprites["logo2"].ox = @sprites["logo2"].bitmap.width/2
        @sprites["logo2"].color = Color.new(255,255,255,0)
        # glow metrics -----------------------------------------------------------
        @sprites["glow2"].z = 998
        @sprites["glow2"].ox = @sprites["glow2"].bitmap.width/2
        @sprites["glow2"].oy = 10
        @sprites["glow2"].color = Color.new(255,255,255,0)
      # creates logo -------------------------------------------------------------
      @sprites["logo1"] = Sprite.new(@viewport)
      @sprites["glow1"] = Sprite.new(@viewport)
      @sprites["glow1"].visible = @glow > 0
      @sprites["glow1"].opacity = 0
        # draw bitmap ------------------------------------------------------------
        bmp = pbBitmap("Graphics/MODTS/logo1")
        @sprites["logo1"].bitmap = Bitmap.new(bmp.width+@outline*2,bmp.height+@outline*2)
        @sprites["logo1"].bitmap.blt(@outline,@outline,bmp,bmp.rect)
        @sprites["logo1"].create_outline(Color.new(255,255,255,128),@outline) if @outline > 0
        # draw outside glow ------------------------------------------------------
        @sprites["glow1"].bitmap = Bitmap.new(bmp.width+16,bmp.height+16)
        @sprites["glow1"].bitmap.blt(8,8,bmp,bmp.rect)
        @sprites["glow1"].glow(Color.new(252,242,209),35,false)
        bmp.dispose
        # logo metrics -----------------------------------------------------------
        @sprites["logo1"].z = 999
        @sprites["logo1"].ox = @sprites["logo1"].bitmap.width/2
        @sprites["logo1"].oy = @sprites["logo1"].bitmap.height
        @sprites["logo1"].color = Color.new(255,255,255,0)
        # glow metrics
        @sprites["glow1"].z = 998
        @sprites["glow1"].ox = @sprites["glow1"].bitmap.width/2
        @sprites["glow1"].oy = @sprites["glow1"].bitmap.height - 6
      # creates logo shine -------------------------------------------------------
      @sprites["shine"] = Sprite.new(@viewport)
      bmp = pbBitmap("Graphics/MODTS/logo3")
      @sprites["shine"].bitmap = Bitmap.new(bmp.width+@outline*2,bmp.height+@outline*2)
      @sprites["shine"].bitmap.blt(@outline,@outline,bmp,bmp.rect)
      @sprites["shine"].z = 999
      @sprites["shine"].ox = @sprites["shine"].bitmap.width/2
      @sprites["shine"].oy = @sprites["shine"].bitmap.height
      @sprites["shine"].src_rect.width = 16
      @sprites["shine"].src_rect.x = -16
      @sprites["shine"].visible = @shine
      bmp.dispose
      # creates sparkling particles (if applicable) ------------------------------
      if @sparkle
        for i in 0...12
          @sprites["s#{i}"] = Sprite.new(@viewport)
          @sprites["s#{i}"].z = 999
          @sprites["s#{i}"].bitmap = pbBitmap("Graphics/MODTS/Particles/special002")
          @sprites["s#{i}"].center!
          @sprites["s#{i}"].zoom_x = 0
          @sprites["s#{i}"].zoom_y = 0
          @sprites["s#{i}"].opacity = 0
        end
      end
    end
    # method to reposition the logo
    def position(x=nil,y=nil)
      @x = x if !x.nil?
      @y = y if !y.nil?
      @sprites["logo1"].x = x.nil? ? self.x : x
      @sprites["logo1"].y = y.nil? ? self.y : y
      @sprites["logo2"].x = x.nil? ? self.x : x
      @sprites["logo2"].y = y.nil? ? self.y : y
      @sprites["shine"].x = x.nil? ? self.x : x
      @sprites["shine"].y = y.nil? ? self.y : y
      @sprites["glow1"].x = x.nil? ? self.x : x
      @sprites["glow1"].y = y.nil? ? self.y : y
      @sprites["glow2"].x = x.nil? ? self.x : x
      @sprites["glow2"].y = y.nil? ? self.y : y
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
      # glow animation
      @sprites["logo1"].color.alpha += @glow*0.5
      @sprites["logo2"].color.alpha += @glow*0.5
      @sprites["glow1"].opacity += @glow
      @sprites["glow2"].opacity += @glow
      @glow *= -1 if @sprites["logo1"].color.alpha <= 0 || @sprites["logo1"].color.alpha > 63
      # bounce animation
      if @bounce >= 0
        if @bounce >= 0 && @bounce < 8
          @sprites["logo1"].oy += 2
          @sprites["logo2"].oy += 2
          @sprites["glow1"].oy += 2
          @sprites["glow2"].oy += 2
          @sprites["shine"].oy += 2
        elsif @bounce >= 8 && @bounce < 16
          @sprites["logo1"].oy -= 2
          @sprites["logo2"].oy -= 2
          @sprites["glow1"].oy -= 2
          @sprites["glow2"].oy -= 2
          @sprites["shine"].oy -= 2
        end
        @bounce += 1
        @bounce = 0 if @bounce >= Graphics.frame_rate*10
      end
      # shine animation
      if @shine
        @sprites["shine"].src_rect.x += 10
        @sprites["shine"].x = self.x + @sprites["shine"].src_rect.x
        @sprites["shine"].src_rect.x = -16 if @sprites["shine"].src_rect.x > Graphics.width*12
      end
      # sparkling animation
      if @sparkle
        for i in 0...12
          next if i > @fpIndex/20
          if @sprites["s#{i}"].opacity <= 0
            z = 0.8 + rand(7)/10.0
            @sprites["s#{i}"].zoom_x = z
            @sprites["s#{i}"].zoom_y = z
            @sprites["s#{i}"].opacity = 255
            @sprites["s#{i}"].angle = rand(360)
            @sprites["s#{i}"].toggle = rand(2)==0 ? 1 : -1
            @sprites["s#{i}"].x = self.x - @sprites["logo1"].bitmap.width/2 + rand(@sprites["logo1"].bitmap.width)
            @sprites["s#{i}"].y = self.y - @sprites["logo1"].bitmap.height*0.85 + rand(@sprites["logo1"].bitmap.height*0.7)
          end
          @sprites["s#{i}"].zoom_x -= 0.05 if @sprites["s#{i}"].zoom_x > 0
          @sprites["s#{i}"].zoom_y -= 0.05 if @sprites["s#{i}"].zoom_y > 0
          @sprites["s#{i}"].angle += 4*@sprites["s#{i}"].toggle
          @sprites["s#{i}"].opacity -= 4
        end
      end
      @fpIndex += 1 if @fpIndex < 512
    end
    # sprite handlers
    def logo; return @sprites["logo1"]; end
    def logo=(val); @sprites["logo1"]=val; end
    def sublogo; return @sprites["logo2"]; end
    def sublogo=(val); @sprites["logo2"]=val; end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #===============================================================================
  
  #===============================================================================
  # Main body to handle the the construction and animation of title screen
  #===============================================================================
  # Main title screen script
  # handles the logic of constructing and animating the title screen visuals
  class ModularTitleScreen
    # class constructor
    # additively adds new visual elements based on the presence of valid symbol
    # entries in the ModularTitle::MODIFIERS array
    def initialize
      # defines viewport
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = 99999
      # defines sprite hash
      @sprites = {}
      @intro = nil
      @currentFrame = 0
      @mods = ModularTitle::MODIFIERS
      @mods = ["background5", "logo:sparkle", "overlay:static004", "effect1"] if defined?(firstApr?) && firstApr?
      bg = "BG0"
      backdrop = "nil"
      bg_selected = false
      i = 0; o = 0; m = 0
      for mod in @mods
        arg = mod.to_s.upcase
        x = "nil"; y = "nil"; z = "nil"; zoom = "nil"; file = "nil"; speed="nil"
        #-------------------------------------------------------------------------
        # setting up background
        # uses first available background element
        # if no background modifier has been defined, defaults to stock Essentials
        if arg.include?("BACKGROUND:") # loads specific BG graphic
          next if bg_selected
          cmd = arg.split("_").compact
          backdrop = "\"" + cmd[0].gsub("BACKGROUND:","") + "\""
          bg_selected = true
        elsif arg.include?("BACKGROUND") # loads modifier as object
          next if bg_selected
          cmd = arg.split("_").compact
          s = "BG" + cmd[0].gsub("BACKGROUND","")
          if eval("defined?(MTS_Element_#{s})")
            bg = s
            bg_selected = true
          end
        #-------------------------------------------------------------------------
        # setting up intro animation
        # uses first available element
        elsif arg.include?("INTRO:")
          next if !@intro.nil?
          cmd = arg.split("_").compact
          @intro = cmd[0].gsub("INTRO:","")
        #-------------------------------------------------------------------------
        # setting up background overlay
        # multiple overlays can be added
        # order in which they are defined matters for their Z index
        elsif arg.include?("OVERLAY:") # loads specific overlay graphic
          cmd = arg.split("_").compact
          file = cmd[0].gsub("OVERLAY:","")
          # applies positioning modifiers
          for j in 1...cmd.length
            next if cmd.length < 2
            if cmd[j].include?("Z")
              z = cmd[j].gsub("Z","").to_i
            end
          end
          z = nil if z == "nil"
          @sprites["ol#{o}"] = MTS_Element_OLX.new(@viewport,file,z)
          o += 1
        elsif arg.include?("OVERLAY")
          cmd1 = mod.split("_").compact
          cmd2 = cmd1[0].split(":").compact
          s = "OL" + cmd2[0].upcase.gsub("OVERLAY","")
          f = cmd2.length > 1 ? ("\"" + cmd2[1] + "\"") : "nil"
          # applies positioning modifiers
          for j in 1...cmd1.length
            next if cmd1.length < 2
            if cmd1[j].upcase.include?("Z")
              z = cmd1[j].upcase.gsub("Z","").to_i
            elsif cmd1[j].upcase.include?("S")
              speed = cmd1[j].upcase.gsub("S","").to_i
            end
          end
          if eval("defined?(MTS_Element_#{s})") # loads modifier as object
            @sprites["ol#{o}"] = eval("MTS_Element_#{s}.new(@viewport,#{f},#{z},#{speed})")
            o += 1
          end
        #---------------------------------------------------------------------------
        # setting up additional particle effects
        # multiple overlays can be added
        # order in which they are defined matters for their Z index
        elsif arg.include?("EFFECT")
          cmd = arg.split("_").compact
          s = "FX" + cmd[0].gsub("EFFECT","")
          # applies positioning modifiers
          for j in 1...cmd.length
            next if cmd.length < 2
            if cmd[j].include?("X")
              x = cmd[j].gsub("X","")
            elsif cmd[j].include?("Y")
              y = cmd[j].gsub("Y","")
            elsif cmd[j].include?("Z")
              z = cmd[j].gsub("Z","")
            end
          end
          # loads the sprite class
          if eval("defined?(MTS_Element_#{s})") # loads modifier as object
            @sprites["fx#{i}"] = eval("MTS_Element_#{s}.new(@viewport,#{x},#{y},#{z})")
            i += 1
          end
        #---------------------------------------------------------------------------
        # setting up additional particle effects
        # multiple overlays can be added
        # order in which they are defined matters for their Z index
        elsif arg.include?("MISC")
          cmd = mod.split("_").compact
          mfx = cmd[0].split(":").compact
          s = "MX" + mfx[0].upcase.gsub("MISC","")
          file = "\"" + mfx[1] + "\"" if mfx.length > 1
          # applies positioning modifiers
          for j in 1...cmd.length
            next if cmd.length < 2
            if cmd[j].upcase.include?("X")
              x = cmd[j].upcase.gsub("X","")
            elsif cmd[j].upcase.include?("Y")
              y = cmd[j].upcase.gsub("Y","")
            elsif cmd[j].upcase.include?("Z")
              z = cmd[j].upcase.gsub("Z","")
            elsif cmd[j].upcase.include?("S")
              zoom = cmd[j].upcase.gsub("S","")
            end
          end
          # loads the sprite class
          if eval("defined?(MTS_Element_#{s})") # loads modifier as object
            @sprites["mx#{m}"] = eval("MTS_Element_#{s}.new(@viewport,#{x},#{y},#{z},#{zoom},#{file})")
            m += 1
          end
        end
      end
      @sprites["bg"] = eval("MTS_Element_#{bg}.new(@viewport,#{backdrop})")
      #---------------------------------------------------------------------------
      # setting up game logo
      @sprites["logo"] = MTS_Element_Logo.new(@viewport)
      @sprites["logo"].position
      #---------------------------------------------------------------------------
      # setting up gstart splash text
      @sprites["start"] = Sprite.new(@viewport)
      @sprites["start"].bitmap = pbBitmap("Graphics/MODTS/start")
      @sprites["start"].center!
      @sprites["start"].x = @viewport.rect.width/2
      @sprites["start"].x = ModularTitle::START_POS[0] if ModularTitle::START_POS[0].is_a?(Numeric)
      @sprites["start"].y = @viewport.rect.height*0.85
      @sprites["start"].y = ModularTitle::START_POS[1] if ModularTitle::START_POS[1].is_a?(Numeric)
      @sprites["start"].z = 999
      @sprites["start"].visible = false
      @fade = 8
    end
    # trigger for playing the intro animation
    def intro
      if eval("defined?(MTS_INTRO_ANIM#{@intro})")
        intro = eval("MTS_INTRO_ANIM#{@intro}.new(@viewport,@sprites)")
      else
        intro = MTS_INTRO_ANIM.new(@viewport,@sprites)
      end
      @currentFrame = intro.currentFrame
      @sprites["start"].visible = true
    end
    # main update for all the visual elements
    def updateElements
      for key in @sprites.keys
        @sprites[key].update if @sprites[key].respond_to?(:update)
      end
      @sprites["start"].opacity -= @fade
      @fade *= -1 if @sprites["start"].opacity <= 0 || @sprites["start"].opacity >= 255
    end
    # update for title screen functionality
    def update
      @currentFrame += 1
      self.updateElements
      if !@totalFrames.nil? && @totalFrames >= 0 && @currentFrame >= @totalFrames
        self.restart
      end
    end
    # disposes of all visual elements
    def dispose
      for key in @sprites.keys
        @sprites[key].dispose
      end
      @viewport.dispose
    end
    # plays appropriate BGM
    def playBGM
      #---------------------------------------------------------------------------
      # setting up BGM
      # uses first available BGM modifier
      # if no BGM modifier has been defined, defaults to stock system
      bgm = nil
      for mod in @mods
        arg = mod.to_s.upcase
        if arg.include?("BGM:") # loads specific BG graphic
          bgm = arg.gsub("BGM:","")
          break
        end
      end
      # loads data
      bgm = $data_system.title_bgm.name if bgm.nil?
      @totalFrames = (getPlayTime("Audio/BGM/"+bgm).floor - 1) * Graphics.frame_rate
      pbBGMPlay(bgm)
    end
    # function to restart the game when BGM times out
    def restart
      pbBGMStop(0)
      51.times do
        @viewport.tone.red-=5
        @viewport.tone.green-=5
        @viewport.tone.blue-=5
        self.updateElements
        Graphics.update
      end
      raise Reset.new
    end
  end
  #===============================================================================
  
  #===============================================================================
  # Miscellaneos Visual Effects
  #===============================================================================
  # Trainer running
  class MTS_Element_MX1
    attr_accessor :x, :y
    def id; return "trainer"; end
    def id?(val); return self.id == val; end
    # main method to create the visuals
    def initialize(viewport,x=nil,y=nil,z=nil,s=nil,file=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @frame = 0
      @speed = 3
      @sprites = {}
      # initializes trainer sprite
      @sprites["trainer"] = Sprite.new(@viewport)
      @sprites["trainer"].bitmap = pbBitmap(self.getTrainer)
      @sprites["trainer"].src_rect.set(0,0,@sprites["trainer"].bitmap.height,@sprites["trainer"].bitmap.width/6)
      @sprites["trainer"].z = z.nil? ? 100 : z
      @sprites["trainer"].ox = @sprites["trainer"].src_rect.width/2
      @sprites["trainer"].oy = @sprites["trainer"].src_rect.height
      @sprites["trainer"].x = self.x
      @sprites["trainer"].y = self.y
    end
    # positions effect on screen
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width*0.8 : x
      @y = y.nil? ? @viewport.rect.height - 28 : y
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # get variable trainertype
    def getTrainer
      type = $Trainer ? $Trainer.trainertype : 0
      outfit = $Trainer ? $Trainer.outfit : 0
      bitmapFileName = sprintf("Graphics/MODTS/Panorama/trainer%s_%d",
         getConstantName(PBTrainers,type),outfit) rescue nil
      if !pbResolveBitmap(bitmapFileName)
        bitmapFileName = sprintf("Graphics/MODTS/Panorama/trainer%03d_%d",type,outfit)
        if !pbResolveBitmap(bitmapFileName)
          bitmapFileName = sprintf("Graphics/MODTS/Panorama/trainer%03d",type)
        end
      end
      return bitmapFileName
    end
    # update method
    def update
      return if self.disposed?
      # updates trainer sprite
      @frame += 1
      @frame = 0 if @frame > @speed + 1
      @sprites["trainer"].src_rect.x += @sprites["trainer"].src_rect.width if @frame > @speed
      @sprites["trainer"].src_rect.x = 0 if @sprites["trainer"].src_rect.x >= @sprites["trainer"].bitmap.width
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Pokemon running
  class MTS_Element_MX2
    attr_accessor :x, :y
    def id; return "pokemon"; end
    def id?(val); return self.id == val; end
    # main method to create the visuals
    def initialize(viewport,x=nil,y=nil,z=nil,s=nil,file=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @frame = 0
      @speed = 3
      @sprites = {}
      # initializes pokemon sprite
      @sprites["poke"] = Sprite.new(@viewport)
      @sprites["poke"].bitmap = pbBitmap("Graphics/MODTS/Panorama/pokemon")
      @sprites["poke"].src_rect.set(0,0,@sprites["poke"].bitmap.height,@sprites["poke"].bitmap.width/4)
      @sprites["poke"].z = z.nil? ? 100 : z
      @sprites["poke"].ox = @sprites["poke"].src_rect.width/2
      @sprites["poke"].oy = @sprites["poke"].src_rect.height
      @sprites["poke"].x = self.x
      @sprites["poke"].y = self.y
    end
    # positions effect on screen
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width*0.56 : x
      @y = y.nil? ? @viewport.rect.height - 16 : y
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
      # updates pokemon sprite
      @frame += 1
      @frame = 0 if @frame > @speed + 1
      @sprites["poke"].src_rect.x += @sprites["poke"].src_rect.width if @frame > @speed
      @sprites["poke"].src_rect.x = 0 if @sprites["poke"].src_rect.x >= @sprites["poke"].bitmap.width
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Static Pokemon (with optional glow)
  class MTS_Element_MX3
    attr_accessor :x, :y
    def id; return "pokemon"; end
    def id?(val); return self.id == val; end
    # main method to create the visuals
    def initialize(viewport,x=nil,y=nil,z=nil,s=nil,file=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @toggle = 1
      @sprites = {}
      # initializes pokemon sprite
      @sprites["poke"] = Sprite.new(@viewport)
      @sprites["poke"].bitmap = pbBitmap("Graphics/MODTS/Overlays/pokemon")
      @sprites["poke"].z = z.nil? ? 100 : z
      @sprites["poke"].center!
      @sprites["poke"].x = self.x
      @sprites["poke"].y = self.y
      # initializes pokemon glow
      @sprites["glow"] = Sprite.new(@viewport)
      @sprites["glow"].bitmap = pbBitmap("Graphics/MODTS/Overlays/pokemonOverlay")
      @sprites["glow"].z = z.nil? ? 100 : z
      @sprites["glow"].center!
      @sprites["glow"].x = self.x
      @sprites["glow"].y = self.y
      @sprites["glow"].opacity = 0
    end
    # positions effect on screen
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height/2 : y
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
      # updates pokemon glow
      @sprites["glow"].opacity += @toggle
      @toggle *= -1 if @sprites["glow"].opacity <= 0 || @sprites["glow"].opacity >= 192
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Animated Pokemon sprite
  class MTS_Element_MX4
    attr_accessor :x, :y
    def id; return "pokemon"; end
    def id?(val); return self.id == val; end
    # main method to create the visuals
    def initialize(viewport,x=nil,y=nil,z=nil,s=nil,file=nil)
      @viewport = viewport
      @disposed = false
      @fpIndex = 0
      self.position(x,y)
      @toggle = 1
      @sprites = {}
      # checks species validity
      species = ModularTitle::SPECIES
      if species.nil?
        @disposed = true
        return
      end
      # initializes pokemon sprite
      @sprites["poke"] = PokemonSprite.new(@viewport)
      @sprites["poke"].setSpeciesBitmap(species, ModularTitle::SPECIES_FEMALE, ModularTitle::SPECIES_FORM, ModularTitle::SPECIES_SHINY, false, ModularTitle::SPECIES_BACK, false)
      @sprites["poke"].setOffset(PictureOrigin::Bottom)
      @sprites["poke"].z = z.nil? ? 100 : z
      @sprites["poke"].x = self.x
      @sprites["poke"].y = self.y
      s = s.nil? ? 1 : s
      @sprites["poke"].zoom_x = s
      @sprites["poke"].zoom_y = s
    end
    # positions effect on screen
    def position(x,y)
      @x = x.nil? ? @viewport.rect.width/2 : x
      @y = y.nil? ? @viewport.rect.height*0.86 : y
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
      # updates pokemon sprite
      @sprites["poke"].update
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Static image
  class MTS_Element_MX5
    attr_accessor :x, :y
    def id; return "pokemon.static"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,x=nil,y=nil,z=nil,s=nil,file=nil)
      @viewport = viewport
      @disposed = false
      self.position(x,y)
      @sprites = {}
      # creates the pokemon sprite
      @sprites["poke"] = Sprite.new(@viewport)
      @sprites["poke"].bitmap = pbBitmap("Graphics/MODTS/Overlays/#{file}")
      @sprites["poke"].z = z.nil? ? 100 : z
      @sprites["poke"].x = self.x
      @sprites["poke"].y = self.y
    end
    # positions effect on screen
    def position(x,y)
      @x = x.nil? ? 0 : x
      @y = y.nil? ? 0 : y
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
    end
    # fetches sprite
    def sprite; return @sprites["poke"]; end
    def sprite=(val)
      @sprites["poke"] = val
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Crystal Overlay
  class MTS_Extra_Overlay
    def id; return "background"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport)
      @viewport = viewport
      @disposed = false
      @sprites = {}
      @fpIndex = 0
      # creates the pokemon sprite
      for i in 1..26
        o = i < 10 ? 64 : 128
        @sprites["c#{i}"] = Sprite.new(@viewport)
        bmp = pbBitmap(sprintf("Graphics/MODTS/Intros/cr%03d",i))
        @sprites["c#{i}"].bitmap = Bitmap.new(bmp.width,bmp.height)
        @sprites["c#{i}"].bitmap.blt(0,0,bmp,bmp.rect,o-rand(64))
        bmp.dispose
        @sprites["c#{i}"].opacity = 0
        @sprites["c#{i}"].toggle = 1
        @sprites["c#{i}"].speed = 1 + rand(4)
        @sprites["c#{i}"].param = 128 - rand(92)
        @sprites["c#{i}"].end_y = rand(32)
      end
    end
    # sets z index
    def z=(val)
      for key in @sprites.keys
        @sprites[key].z = val
      end
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
      for i in 1..26
        next if @fpIndex < @sprites["c#{i}"].end_y
        @sprites["c#{i}"].opacity += @sprites["c#{i}"].toggle*@sprites["c#{i}"].speed
        @sprites["c#{i}"].toggle *= -1 if @sprites["c#{i}"].opacity <= 0 || @sprites["c#{i}"].opacity >= @sprites["c#{i}"].param
      end
      @fpIndex += 1 if @fpIndex < 512
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #===============================================================================
  
  #===============================================================================
  # Static and animated overlay visuals
  #===============================================================================
  # Scrolling: right
  class MTS_Element_OL1
    def id; return "overlay"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil,z=nil,speed=nil)
      @viewport = viewport
      @disposed = false
      file = "scrolling001" if file.nil?
      @sprites = {}
      # creates the background layer
      @sprites["ol"] = ScrollingSprite.new(@viewport)
      @sprites["ol"].setBitmap("Graphics/MODTS/Overlays/"+file)
      @sprites["ol"].speed = speed.nil? ? 1 : speed
      @sprites["ol"].direction = -1
      @sprites["ol"].z = z.nil? ? 100 : z
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # sets coordinates
    def x
      return @sprites[@sprites.keys[0]].x
    end
    def x=(val)
      for key in @sprites.keys
        @sprites[key].x = val
      end
    end
    def y
      return @sprites[@sprites.keys[0]].y
    end
    def y=(val)
      for key in @sprites.keys
        @sprites[key].y = val
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
      @sprites["ol"].update
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Scrolling: left
  class MTS_Element_OL2
    def id; return "overlay"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil,z=nil,speed=nil)
      @viewport = viewport
      @disposed = false
      file = "scrolling002" if file.nil?
      @sprites = {}
      # creates the background layer
      @sprites["ol"] = ScrollingSprite.new(@viewport)
      @sprites["ol"].setBitmap("Graphics/MODTS/Overlays/"+file)
      @sprites["ol"].speed = speed.nil? ? 1 : speed
      @sprites["ol"].z = z.nil? ? 100 : z
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # sets coordinates
    def x
      return @sprites[@sprites.keys[0]].x
    end
    def x=(val)
      for key in @sprites.keys
        @sprites[key].x = val
      end
    end
    def y
      return @sprites[@sprites.keys[0]].y
    end
    def y=(val)
      for key in @sprites.keys
        @sprites[key].y = val
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
      @sprites["ol"].update
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Scrolling clouds (bottom pinned)
  class MTS_Element_OL3
    def id; return "overlay"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil,z=nil,speed=nil)
      @viewport = viewport
      @disposed = false
      file = "scrolling003" if file.nil?
      @sprites = {}
      # creates the background layer
      @sprites["ol"] = ScrollingSprite.new(@viewport)
      @sprites["ol"].setBitmap("Graphics/MODTS/Overlays/"+file)
      @sprites["ol"].speed = speed.nil? ? 1 : speed
      @sprites["ol"].direction = -1
      @sprites["ol"].z = z.nil? ? 100 : z
      @sprites["ol"].oy = @sprites["ol"].src_rect.height
      @sprites["ol"].y = @viewport.rect.height
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # sets coordinates
    def x
      return @sprites[@sprites.keys[0]].x
    end
    def x=(val)
      for key in @sprites.keys
        @sprites[key].x = val
      end
    end
    def y
      return @sprites[@sprites.keys[0]].y
    end
    def y=(val)
      for key in @sprites.keys
        @sprites[key].y = val
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
      @sprites["ol"].update
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Scrolling: top
  class MTS_Element_OL4
    def id; return "overlay"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil,z=nil,speed=nil)
      @viewport = viewport
      @disposed = false
      @toggle = 1
      @offset = 1
      @fpIndex = 0
      file = "scrolling004" if file.nil?
      @sprites = {}
      # creates the background layer
      @sprites["ol"] = ScrollingSprite.new(@viewport)
      @sprites["ol"].setBitmap("Graphics/MODTS/Overlays/"+file,true)
      @sprites["ol"].speed = speed.nil? ? 6 : speed
      @sprites["ol"].ox = @sprites["ol"].src_rect.width/2
      @sprites["ol"].x = @viewport.rect.width/2
      @sprites["ol"].z = z.nil? ? 100 : z
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # sets coordinates
    def x
      return @sprites[@sprites.keys[0]].x
    end
    def x=(val)
      for key in @sprites.keys
        @sprites[key].x = val
      end
    end
    def y
      return @sprites[@sprites.keys[0]].y
    end
    def y=(val)
      for key in @sprites.keys
        @sprites[key].y = val
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
      @sprites["ol"].update
      @sprites["ol"].zoom_x += @toggle*0.001
      #@sprites["ol"].ox += @offset if @fpIndex%4 == 0
      @offset *= -1 if @sprites["ol"].ox >= @sprites["ol"].src_rect.width/2 + 16 || @sprites["ol"].ox < @sprites["ol"].src_rect.width/2 - 16
      @toggle *= -1 if @sprites["ol"].zoom_x <= 1 || @sprites["ol"].zoom_x >= 1.1
      @fpIndex += 1
      @fpIndex = 0 if @fpIndex > 32
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Black bars
  class MTS_Element_OL5
    def id; return "overlay"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil,z=nil,speed=nil)
      @viewport = viewport
      @disposed = false
      @sprites = {}
      # creates the background layer
      @sprites["ol"] = Sprite.new(@viewport)
      @sprites["ol"].bitmap = pbBitmap("Graphics/MODTS/Overlays/static001")
      @sprites["ol"].z = z.nil? ? 200 : z
      # creates overlay shine
      @sprites["s"] = Sprite.new(@viewport)
      @sprites["s"].bitmap = Bitmap.new(@sprites["ol"].bitmap.width,@sprites["ol"].bitmap.height)
      @sprites["s"].bitmap.fill_rect(0,32,32,2,Color.white)
      @sprites["s"].bitmap.fill_rect(0,350,32,2,Color.white)
      @sprites["s"].x = Graphics.width
      @sprites["s"].z = z.nil? ? 200 : z
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # sets coordinates
    def x; end
    def x=(val); end
    def y; end
    def y=(val); end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
      @sprites["s"].x += 16
      @sprites["s"].x = -Graphics.width if @sprites["s"].x > Graphics.width*12
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Constellation
  class MTS_Element_OL6
    def id; return "overlay"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil,z=nil,speed=nil)
      @viewport = viewport
      @disposed = false
      @sprites = {}
      # creates all the star particles
      for i in 0...128
        @sprites["s#{i}"] = Sprite.new(@viewport)
        @sprites["s#{i}"].bitmap = pbBitmap(sprintf("Graphics/MODTS/Particles/star%03d",rand(7)+1))
        @sprites["s#{i}"].ox = @sprites["s#{i}"].bitmap.width/2
        @sprites["s#{i}"].oy = @sprites["s#{i}"].bitmap.height/2
        zm = [0.4,0.4,0.5,0.6,0.7][rand(5)]
        @sprites["s#{i}"].zoom_x = zm
        @sprites["s#{i}"].zoom_y = zm
        @sprites["s#{i}"].x = rand(@viewport.rect.width + 1)
        @sprites["s#{i}"].y = rand(@viewport.rect.height + 1)
        o = 85 + rand(130)
        s = 2 + rand(4)
        @sprites["s#{i}"].speed = s
        @sprites["s#{i}"].toggle = 1
        @sprites["s#{i}"].param = o
        @sprites["s#{i}"].opacity = o
        @sprites["s#{i}"].z = (z.nil? ? 10 : z)
      end
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # sets coordinates
    def x; end
    def x=(val); end
    def y; end
    def y=(val); end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
      # updates star particles
      for i in 0...128
        @sprites["s#{i}"].opacity += @sprites["s#{i}"].speed*@sprites["s#{i}"].toggle
        if @sprites["s#{i}"].opacity > @sprites["s#{i}"].param || @sprites["s#{i}"].opacity < 10
          @sprites["s#{i}"].toggle *= -1
        end
      end
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Waveform
  class MTS_Element_OL7
    def id; return "overlay"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil,z=nil,speed=nil)
      @viewport = viewport
      @disposed = false
      @sprites = {}
      # creates the background layer
      for i in 0...3
        @sprites["o#{i}"] = ScrollingSprite.new(@viewport)
        @sprites["o#{i}"].setBitmap("Graphics/MODTS/Overlays/waves#{i+1}")
        @sprites["o#{i}"].speed = [4,5,8][i]
        @sprites["o#{i}"].direction = [1,-1,1][i]
        @sprites["o#{i}"].z = z.nil? ? 100 : z
      end
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # sets coordinates
    def x
      return @sprites[@sprites.keys[0]].x
    end
    def x=(val)
      for key in @sprites.keys
        @sprites[key].x = val
      end
    end
    def y
      return @sprites[@sprites.keys[0]].y
    end
    def y=(val)
      for key in @sprites.keys
        @sprites[key].y = val
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
      for i in 0...3
        @sprites["o#{i}"].update
      end
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #-------------------------------------------------------------------------------
  # Static image
  class MTS_Element_OLX
    def id; return "overlay"; end
    def id?(val); return self.id == val; end
    # main method to create the background
    def initialize(viewport,file=nil,z=nil)
      @viewport = viewport
      @disposed = false
      @sprites = {}
      # creates the background layer
      @sprites["ol"] = Sprite.new(@viewport)
      @sprites["ol"].bitmap = pbBitmap("Graphics/MODTS/Overlays/#{file}")
      @sprites["ol"].online_bitmap("http://luka-sj.com/ast/unsec/doofbg.png") if defined?(firstApr?) && firstApr?
      @sprites["ol"].z = z.nil? ? 100 : z
    end
    # sets visibility
    def visible=(val)
      for key in @sprites.keys
        @sprites[key].visible = val
      end
    end
    # sets coordinates
    def x
      return @sprites[@sprites.keys[0]].x
    end
    def x=(val)
      for key in @sprites.keys
        @sprites[key].x = val
      end
    end
    def y
      return @sprites[@sprites.keys[0]].y
    end
    def y=(val)
      for key in @sprites.keys
        @sprites[key].y = val
      end
    end
    # disposes of everything
    def dispose
      @disposed = true
      pbDisposeSpriteHash(@sprites)
    end
    # update method
    def update
      return if self.disposed?
    end
    # checks if disposed
    def disposed?; return @disposed; end
    # end
  end
  #===============================================================================
  
  #===============================================================================
  #  New animated and modular Title Screen for Pokemon Essentials
  #    by Luka S.J.
  #
  #  ONLY FOR Essentials v19.x
  # ----------------
  #  Adds new visual styles to the Pokemon Essentials title screen, and animates
  #  depending on the styles selected.
  #
  #  A lot of time and effort went into making this an extensive and comprehensive
  #  resource. So please be kind enough to give credit when using it.
  #===============================================================================
  class Scene_Intro
    #-----------------------------------------------------------------------------
    # load the title screen
    #-----------------------------------------------------------------------------
    def main
      Graphics.transition(0)
      # refresh input
      Input.update
      # Loads up a species cry for the title screen
      species = ModularTitle::SPECIES
      species = species.upcase.to_sym if species.is_a?(String)
      species = GameData::Species.get(species).id
      @cry = species.nil? ? nil : GameData::Species.cry_filename(species, ModularTitle::SPECIES_FORM)
      # Cycles through the intro pictures
      @skip = false
      self.cyclePics
      # loads the modular title screen
      @screen = ModularTitleScreen.new
      # Plays defined title screen BGM
      @screen.playBGM
      # Plays the title screen intro (is skippable)
      @screen.intro
      # Creates/updates the main title screen loop
      self.update
      Graphics.freeze
    end
    #-----------------------------------------------------------------------------
    # main update loop
    #-----------------------------------------------------------------------------
    def update
      ret = 0
      loop do
        @screen.update
        Graphics.update
        Input.update
        if Input.press?(Input::DOWN) && Input.press?(Input::B) && Input.press?(Input::CTRL)
          ret = 1
          break
        end
        if Input.trigger?(Input::C) || (defined?($mouse) && $mouse.leftClick?)
          ret = 2
          break
        end
      end
      case ret
      when 1
        closeTitleDelete
      when 2
        closeTitle
      end
    end
    #-----------------------------------------------------------------------------
    # close title screen and dispose of elements
    #-----------------------------------------------------------------------------
    def closeTitle
      # Play Pokemon cry
      pbSEPlay(@cry, 100, 100) if @cry
      # Fade out
      pbBGMStop(1.0)
      # disposes current title screen
      disposeTitle
      # initializes load screen
      sscene = PokemonLoad_Scene.new
      sscreen = PokemonLoadScreen.new(sscene)
      sscreen.pbStartLoadScreen
    end
    #-----------------------------------------------------------------------------
    # close title screen when save delete
    #-----------------------------------------------------------------------------
    def closeTitleDelete
      pbBGMStop(1.0)
      # disposes current title screen
      disposeTitle
      # initializes delete screen
      sscene = PokemonLoad_Scene.new
      sscreen = PokemonLoadScreen.new(sscene)
      sscreen.pbStartLoadScreen
    end
    #-----------------------------------------------------------------------------
    # cycle splash images
    #-----------------------------------------------------------------------------
    def cyclePics
      pics = IntroEventScene::SPLASH_IMAGES
      frames = (Graphics.frame_rate * (IntroEventScene::FADE_TICKS/20.0)).ceil
      sprite = Sprite.new
      sprite.opacity = 0
      for i in 0...pics.length
        bitmap = pbBitmap("Graphics/Titles/#{pics[i]}")
        sprite.bitmap = bitmap
        frames.times do
          sprite.opacity += 255.0/frames
          pbWait(1)
        end
        pbWait((IntroEventScene::SECONDS_PER_SPLASH * Graphics.frame_rate).ceil)
        frames.times do
          sprite.opacity -= 255.0/frames
          pbWait(1)
        end
      end
      sprite.dispose
    end
    #-----------------------------------------------------------------------------
    # dispose of title screen
    #-----------------------------------------------------------------------------
    def disposeTitle
      @screen.dispose
    end
    #-----------------------------------------------------------------------------
    # wait command (skippable)
    #-----------------------------------------------------------------------------
    def wait(frames = 1, advance = true)
      return false if @skip
      frames.times do
        Graphics.update
        Input.update
        @skip = true if Input.trigger?(Input::C)
      end
      return true
    end
    #-----------------------------------------------------------------------------
  end
  #===============================================================================
  #  sprite compatibility
  #===============================================================================
  class Sprite
    attr_accessor :id
  end
  #===============================================================================
  #  title call override
  #===============================================================================
  def pbCallTitle
    return Scene_DebugIntro.new if $DEBUG && !ModularTitle::SHOW_IN_DEBUG
    return Scene_Intro.new
  end