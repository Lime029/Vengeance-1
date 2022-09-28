#===============================================================================
# Compile & save ZUD related data.
#===============================================================================
module Compiler
    module_function
    
    alias _ZUD_write_all write_all
    def write_all
      _ZUD_write_all
      write_ZUD_PowerMoves
    end
    
    #-----------------------------------------------------------------------------
    # Compiles Power Move compatibility data from the ZUD_PowerMoves.txt.
    #-----------------------------------------------------------------------------
    def compile_ZUD_PowerMoves
      z_id = 0
      compat_id_num = 0
      GameData::PowerMove::DATA.clear
      pbCompilerEachCommentedLine("PBS/ZUD_PowerMoves.txt") { |line, line_no|
        FileLineData.file = "PBS/ZUD_PowerMoves.txt"
        FileLineData.setSection(line_no, "header", nil)
        if line[/^\s*(\w+)\s*=\s*(.*)$/]   # Of the format XXX = YYY
          key = $~[1]
          powermove = true
          schema = GameData::PowerMove::SCHEMA
          record = pbGetCsvRecord($~[2],key,schema[key])
          case key
          #-----------------------------------------------------------------------
          # Power Move entries
          #-----------------------------------------------------------------------
          when "ZMove";       reqs  = record; compat_id = "ZMOVE"    + record[2].to_s
          when "ZMoveEx";     reqs  = record; z_id += 1; compat_id = "ZMOVEEX"  + z_id.to_s
          #-----------------------------------------------------------------------
          # Status Z-Move entries
          #-----------------------------------------------------------------------
          when "AtkBoost1";   atk   = record; compat_id = "ZMOVEATK1";   stage = 1
          when "AtkBoost2";   atk   = record; compat_id = "ZMOVEATK2";   stage = 2
          when "AtkBoost3";   atk   = record; compat_id = "ZMOVEATK3";   stage = 3
          when "DefBoost1";   dfn   = record; compat_id = "ZMOVEDEF1";   stage = 1
          when "DefBoost2";   dfn   = record; compat_id = "ZMOVEDEF2";   stage = 2
          when "DefBoost3";   dfn   = record; compat_id = "ZMOVEDEF3";   stage = 3
          when "SpAtkBoost1"; satk  = record; compat_id = "ZMOVESPATK1"; stage = 1
          when "SpAtkBoost2"; satk  = record; compat_id = "ZMOVESPATK2"; stage = 2
          when "SpAtkBoost3"; satk  = record; compat_id = "ZMOVESPATK3"; stage = 3
          when "SpDefBoost1"; sdef  = record; compat_id = "ZMOVESPDEF1"; stage = 1
          when "SpDefBoost2"; sdef  = record; compat_id = "ZMOVESPDEF2"; stage = 2
          when "SpDefBoost3"; sdef  = record; compat_id = "ZMOVESPDEF3"; stage = 3
          when "SpeedBoost1"; spd   = record; compat_id = "ZMOVESPEED1"; stage = 1
          when "SpeedBoost2"; spd   = record; compat_id = "ZMOVESPEED2"; stage = 2
          when "SpeedBoost3"; spd   = record; compat_id = "ZMOVESPEED3"; stage = 3
          when "AccBoost1";   acc   = record; compat_id = "ZMOVEACC1";   stage = 1
          when "AccBoost2";   acc   = record; compat_id = "ZMOVEACC2";   stage = 2
          when "AccBoost3";   acc   = record; compat_id = "ZMOVEACC3";   stage = 3
          when "EvaBoost1";   eva   = record; compat_id = "ZMOVEEVA1";   stage = 1
          when "EvaBoost2";   eva   = record; compat_id = "ZMOVEEVA2";   stage = 2
          when "EvaBoost3";   eva   = record; compat_id = "ZMOVEEVA3";   stage = 3
          when "OmniBoost1";  omni  = record; compat_id = "ZMOVEOMNI1";  stage = 1
          when "OmniBoost2";  omni  = record; compat_id = "ZMOVEOMNI2";  stage = 2
          when "OmniBoost3";  omni  = record; compat_id = "ZMOVEOMNI3";  stage = 3
          when "HealUser";    heal  = record; compat_id = "ZMOVEHEAL1";  stage = 1
          when "HealSwitch";  heal  = record; compat_id = "ZMOVEHEAL2";  stage = 2
          when "CritBoost";   crit  = record; compat_id = "ZMOVECRIT"
          when "ResetStats";  reset = record; compat_id = "ZMOVERESET"
          when "FocusOnUser"; focus = record; compat_id = "ZMOVEFOCUS"
          end
          #-----------------------------------------------------------------------
          # Registers a new entry in GameData::PowerMove.
          #-----------------------------------------------------------------------
          if powermove
            compat_id_num += 1
            if reqs
              power_type = GameData::PowerMove::ZMOVE    if reqs.length==3 && key=="ZMove"
              power_type = GameData::PowerMove::ZMOVEEX  if reqs.length==4 && key=="ZMoveEx"
            else 
              power_type = GameData::PowerMove::ZSTATUS
            end
            comp_hash = {
              :id            => compat_id,     # Symbol used for this Power Move's data.
              :id_number     => compat_id_num, # ID Number used for this Power Move's data.
              :compat_type   => power_type,    # Type of Power Move (Z-Move, Z-Ex, Z-Status).
              :req_criteria  => reqs,          # Compatibility requirements for this Power Move.
              :status_atk    => [atk,stage],   # Status Z-Moves that boost Attack, and the number of stages.
              :status_def    => [dfn,stage],   # Status Z-Moves that boost Defense, and the number of stages.
              :status_spatk  => [satk,stage],  # Status Z-Moves that boost Sp.Atk, and the number of stages.
              :status_spdef  => [sdef,stage],  # Status Z-Moves that boost Sp.Def, and the number of stages.
              :status_speed  => [spd,stage],   # Status Z-Moves that boost Speed, and the number of stages.
              :status_acc    => [acc,stage],   # Status Z-Moves that boost Accuracy, and the number of stages.
              :status_eva    => [eva,stage],   # Status Z-Moves that boost Evasion, and the number of stages.
              :status_omni   => [omni,stage],  # Status Z-Moves that boost all stats, and the number of stages.
              :status_heal   => [heal,stage],  # Status Z-Moves that heal, and their targets [Self or Switch-in].
              :status_crit   => crit,          # Status Z-Moves that boost critical hit ratio.
              :status_reset  => reset,         # Status Z-Moves that reset the user's lowered stats.
              :status_focus  => focus          # Status Z-Moves that apply the Follow Me effect on the user.
            }
            GameData::PowerMove.register(comp_hash)
          end
        end
      }
      GameData::Species.save
      GameData::PowerMove.save
      Graphics.update
    end
    
    #-----------------------------------------------------------------------------
    # Writes the ZUD_PowerMoves.txt file from Power Moves and Species data.
    #-----------------------------------------------------------------------------
    def write_ZUD_PowerMoves
      File.open("PBS/ZUD_PowerMoves.txt", "wb") { |f|
        f.write("# This installation is part of the ZUD Plugin for Pokemon Essentials v19.\r\n")
        f.write("# Refer to each section below to learn how to edit this file.\r\n")
        f.write("#\r\n")
        f.write("#########################################################################\r\n")
        f.write("# SECTION 1 : Z-MOVES\r\n")
        f.write("#########################################################################\r\n")
        #-------------------------------------------------------------------------
        # Writes generic Z-Moves.
        #-------------------------------------------------------------------------
        f.write("#-----------------------------------\r\n")
        f.write("# A) Generic Z-Move Compatibility\r\n")
        f.write("#-----------------------------------\r\n")
        f.write("# Add a generic Z-Move for a new type in this section, in the format: ZMove = Z-Move Name, Z-Crystal, Move Type.\r\n")
        f.write("#-----------------------------------\r\n")
        GameData::PowerMove.each do |m|
          next if !m.zMove?
          pbSetWindowText(_INTL("Writing Z-Moves {1}...", m.id_number))
          f.write(sprintf("ZMove = %s,%s,%s\r\n", m.power_move, m.reqItem, m.reqType))
        end
        #-------------------------------------------------------------------------
        # Writes exclusive Z-Moves.
        #-------------------------------------------------------------------------
        f.write("#-----------------------------------\r\n")
        f.write("# B) Exclusive Z-Move Compatibility\r\n")
        f.write("#-----------------------------------\r\n")
        f.write("# Add an exclusive Z-Move for a species in this section, in the format: ZMoveEx = Z-Move Name, Z-Crystal, Converted Move, Species_form.\r\n")
        f.write("#-----------------------------------\r\n")
        GameData::PowerMove.each do |m|
          next if !m.zMoveEx?
          pbSetWindowText(_INTL("Writing Z-Moves (Exclusive) {1}...", m.id_number))
          f.write(sprintf("ZMoveEx = %s,%s,%s,%s\r\n", m.power_move, m.reqItem, m.reqMove, m.reqSpecies))
        end
        #-------------------------------------------------------------------------
        # Writes status Z-Moves.
        #-------------------------------------------------------------------------
        f.write("#-------------------------------\r\n")
        f.write("# C) Status Z-Move Compatibility\r\n")
        f.write("#-------------------------------\r\n")
        f.write("# Give a status move a Z-Move effect by adding that move to the array with the desired effect in this section.\r\n")
        f.write("# The following effects are implemented, but go unused by any existing move. Use them if you want:\r\n")
        f.write("# DefBoost2, DefBoost3, SpAtkBoost3, SpDefBoost3, SpeedBoost3, AccBoost2, AccBoost3, EvaBoost2, EvaBoost3, OmniBoost2, OmniBoost3\r\n")
        f.write("#-------------------------------\r\n")
        GameData::PowerMove.each do |z|
          next if !z.zStatus?
          pbSetWindowText(_INTL("Writing Z-Moves (Status) {1}...", z.id_number))
          effect = movelist = nil
          keys   = GameData::PowerMove::SCHEMA.keys
          for i in 0...keys.length
            effect = keys[i].to_s
            next if effect=="MaxMove" || effect=="ZMove"
            #---------------------------------------------------------------------
            # Writes moves that boost Attack.
            #---------------------------------------------------------------------
            if effect=="AtkBoost1"   && !z.status_atk[0].nil?   && z.status_atk[1]==1;   movelist = z.status_atk[0];   end
            if effect=="AtkBoost2"   && !z.status_atk[0].nil?   && z.status_atk[1]==2;   movelist = z.status_atk[0];   end
            if effect=="AtkBoost3"   && !z.status_atk[0].nil?   && z.status_atk[1]==3;   movelist = z.status_atk[0];   end
            #---------------------------------------------------------------------
            # Writes moves that boost Defense.
            #---------------------------------------------------------------------
            if effect=="DefBoost1"   && !z.status_def[0].nil?   && z.status_def[1]==1;   movelist = z.status_def[0];   end
            if effect=="DefBoost2"   && !z.status_def[0].nil?   && z.status_def[1]==2;   movelist = z.status_def[0];   end
            if effect=="DefBoost3"   && !z.status_def[0].nil?   && z.status_def[1]==3;   movelist = z.status_def[0];   end
            #---------------------------------------------------------------------
            # Writes moves that boost Sp.Atk.
            #---------------------------------------------------------------------
            if effect=="SpAtkBoost1" && !z.status_spatk[0].nil? && z.status_spatk[1]==1; movelist = z.status_spatk[0]; end
            if effect=="SpAtkBoost2" && !z.status_spatk[0].nil? && z.status_spatk[1]==2; movelist = z.status_spatk[0]; end
            if effect=="SpAtkBoost3" && !z.status_spatk[0].nil? && z.status_spatk[1]==3; movelist = z.status_spatk[0]; end
            #---------------------------------------------------------------------
            # Writes moves that boost Sp.Def.
            #---------------------------------------------------------------------
            if effect=="SpDefBoost1" && !z.status_spdef[0].nil? && z.status_spdef[1]==1; movelist = z.status_spdef[0]; end
            if effect=="SpDefBoost2" && !z.status_spdef[0].nil? && z.status_spdef[1]==2; movelist = z.status_spdef[0]; end
            if effect=="SpDefBoost3" && !z.status_spdef[0].nil? && z.status_spdef[1]==3; movelist = z.status_spdef[0]; end
            #---------------------------------------------------------------------
            # Writes moves that boost Speed.
            #---------------------------------------------------------------------
            if effect=="SpeedBoost1" && !z.status_speed[0].nil? && z.status_speed[1]==1; movelist = z.status_speed[0]; end
            if effect=="SpeedBoost2" && !z.status_speed[0].nil? && z.status_speed[1]==2; movelist = z.status_speed[0]; end
            if effect=="SpeedBoost3" && !z.status_speed[0].nil? && z.status_speed[1]==3; movelist = z.status_speed[0]; end
            #---------------------------------------------------------------------
            # Writes moves that boost Accuracy.
            #---------------------------------------------------------------------
            if effect=="AccBoost1"   && !z.status_acc[0].nil?   && z.status_acc[1]==1;   movelist = z.status_acc[0];   end
            if effect=="AccBoost2"   && !z.status_acc[0].nil?   && z.status_acc[1]==2;   movelist = z.status_acc[0];   end
            if effect=="AccBoost3"   && !z.status_acc[0].nil?   && z.status_acc[1]==3;   movelist = z.status_acc[0];   end
            #---------------------------------------------------------------------
            # Writes moves that boost Evasion.
            #---------------------------------------------------------------------
            if effect=="EvaBoost1"   && !z.status_eva[0].nil?   && z.status_eva[1]==1;   movelist = z.status_eva[0];   end
            if effect=="EvaBoost2"   && !z.status_eva[0].nil?   && z.status_eva[1]==2;   movelist = z.status_eva[0];   end
            if effect=="EvaBoost3"   && !z.status_eva[0].nil?   && z.status_eva[1]==3;   movelist = z.status_eva[0];   end
            #---------------------------------------------------------------------
            # Writes moves that boost all stats.
            #---------------------------------------------------------------------
            if effect=="OmniBoost1"  && !z.status_omni[0].nil?  && z.status_omni[1]==1;  movelist = z.status_omni[0];  end
            if effect=="OmniBoost2"  && !z.status_omni[0].nil?  && z.status_omni[1]==2;  movelist = z.status_omni[0];  end
            if effect=="OmniBoost3"  && !z.status_omni[0].nil?  && z.status_omni[1]==3;  movelist = z.status_omni[0];  end
            #---------------------------------------------------------------------
            # Writes moves that heal HP.
            #---------------------------------------------------------------------
            if effect=="HealUser"    && !z.status_heal[0].nil?  && z.status_heal[1]==1;  movelist = z.status_heal[0];  end
            if effect=="HealSwitch"  && !z.status_heal[0].nil?  && z.status_heal[1]==2;  movelist = z.status_heal[0];  end
            #---------------------------------------------------------------------
            # Writes all other move effects.
            #---------------------------------------------------------------------
            if effect=="CritBoost"   && !z.status_crit.nil?;       movelist = z.status_crit;     end
            if effect=="ResetStats"  && !z.status_reset.nil?;      movelist = z.status_reset;    end
            if effect=="FocusOnUser" && !z.status_focus.nil?;      movelist = z.status_focus;    end
            break if effect && movelist
          end
          f.write(sprintf("%s = %s\r\n",effect,movelist.join(",")))
        end
      }
      Graphics.update
    end
  end
  
  #===============================================================================
  # Adds Power Moves to load data.
  #===============================================================================
  module GameData
    def self.load_all
      Type.load
      Ability.load
      Move.load
      Item.load
      BerryPlant.load
      Species.load
      Ribbon.load
      Encounter.load
      TrainerType.load
      Trainer.load
      Metadata.load
      MapMetadata.load
      PowerMove.load
    end
  end
  
  
  #-------------------------------------------------------------------------------
  # DO NOT TOUCH!
  #-------------------------------------------------------------------------------
  module Settings
    ZUD_COMPAT = true
  end