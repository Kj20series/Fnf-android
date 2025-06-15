package;

import flixel.FlxG;
import openfl.utils.Assets;
import sys.FileSystem;
import sys.io.File;

class Paths {
    public static final SOUND_EXT = #if android "ogg" #else "ogg" #end;
    public static final MUSIC_EXT = #if android "ogg" #else "ogg" #end;

    public static function getPath(file:String, type:String = "TEXT", library:Null<String> = null):String {
        var modPath:String = getModPath(file);
        if (FileSystem.exists(modPath)) return modPath;

        var full:String = "assets/" + file;
        if (Assets.exists(full)) return full;

        return file;
    }

    public static function getModPath(file:String):String {
        var modFolder = getModFolder();
        var full = modFolder + "/" + file;
        return full;
    }

    public static function getModFolder():String {
        #if android
        return "/sdcard/.PsychEngine/mods";
        #else
        return "mods";
        #end
    }

    public static function sound(key:String):String {
        return getPath("sounds/" + key + "." + SOUND_EXT);
    }

    public static function music(key:String):String {
        return getPath("music/" + key + "." + MUSIC_EXT);
    }

    public static function image(key:String):String {
        return getPath("images/" + key + ".png");
    }

    public static function json(key:String):String {
        return getPath("data/" + key + ".json");
    }

    public static function lua(key:String):String {
        return getPath("scripts/" + key + ".lua");
    }

    public static function txt(key:String):String {
        return getPath("data/" + key + ".txt");
    }
}
