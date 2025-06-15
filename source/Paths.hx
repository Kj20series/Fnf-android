package;

import animateatlas.AtlasFrameMaker;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import openfl.geom.Rectangle;
import flixel.math.FlxRect;
import haxe.xml.Access;
import openfl.system.System;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.FlxSprite;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flash.media.Sound;

using StringTools;

class Paths {
  inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
  inline public static var VIDEO_EXT = "";

  #if MODS_ALLOWED
  public static var ignoreModFolders:Array<String> = [
    'characters','custom_events','custom_notetypes','data','songs',
    'music','sounds','shaders','videos','images','stages',
    'weeks','fonts','scripts','achievements'
  ];

  static public function mods(key:String = ''):String {
    return Path.join([SUtil.getPath(), 'mods', key]);
  }

  static public function modsFont(key:String):String {
    return mods('fonts/' + key);
  }

  static public function modsJson(key:String):String {
    return mods('data/' + key + '.json');
  }

  static public function modsVideo(key:String):String {
    return mods('videos/' + key + VIDEO_EXT);
  }

  static public function modsSounds(path:String, key:String):String {
    return mods(path + '/' + key + '.' + SOUND_EXT);
  }

  static public function modsImages(key:String):String {
    return mods('images/' + key + '.png');
  }

  static public function modsXml(key:String):String {
    return mods('images/' + key + '.xml');
  }

  static public function modsTxt(key:String):String {
    return mods('images/' + key + '.txt');
  }

  static public function modFolders(key:String):String {
    if (currentModDirectory != null && currentModDirectory.length > 0) {
      var fileToCheck = Path.join([SUtil.getPath(), 'mods', currentModDirectory, key]);
      if (FileSystem.exists(fileToCheck)) return fileToCheck;
    }
    return mods(key);
  }

  static public function getModDirectories():Array<String> {
    var list:Array<String> = [];
    var base = mods();
    if (FileSystem.exists(base)) {
      for (folder in FileSystem.readDirectory(base)) {
        var path = Path.join([base, folder]);
        if (FileSystem.isDirectory(path) && !ignoreModFolders.contains(folder)) {
          list.push(folder);
        }
      }
    }
    return list;
  }
  #end

  public static function excludeAsset(key:String) {
    if (!dumpExclusions.contains(key)) dumpExclusions.push(key);
  }

  public static var dumpExclusions:Array<String> = [
    'assets/music/freakyMenu.$SOUND_EXT',
    'assets/shared/music/breakfast.$SOUND_EXT',
    'assets/shared/music/tea-time.$SOUND_EXT',
  ];

  public static function clearUnusedMemory() {
    for (key in currentTrackedAssets.keys()) {
      if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key)) {
        var obj = currentTrackedAssets.get(key);
        @:privateAccess
        if (obj != null) {
          openfl.Assets.cache.removeBitmapData(key);
          FlxG.bitmap._cache.remove(key);
          obj.destroy();
          currentTrackedAssets.remove(key);
        }
      }
    }
    System.gc();
  }

  public static var localTrackedAssets:Array<String> = [];

  public static function clearStoredMemory(?cleanUnused:Bool = false) {
    @:privateAccess
    for (key in FlxG.bitmap._cache.keys()) {
      var obj = FlxG.bitmap._cache.get(key);
      if (obj != null && !currentTrackedAssets.exists(key)) {
        openfl.Assets.cache.removeBitmapData(key);
        FlxG.bitmap._cache.remove(key);
        obj.destroy();
      }
    }
    for (key in currentTrackedSounds.keys()) {
      if (!localTrackedAssets.contains(key) && !dumpExclusions.contains(key) && key != null) {
        Assets.cache.clear(key);
        currentTrackedSounds.remove(key);
      }
    }
    localTrackedAssets = [];
    openfl.Assets.cache.clear("songs");
  }

  static public var currentModDirectory:String = '';
  static public var currentLevel:String;

  public static function setCurrentLevel(name:String) {
    currentLevel = name.toLowerCase();
  }

  public static function getPath(file:String, type:AssetType, ?library:Null<String> = null) {
    if (library != null) return getLibraryPath(file, library);
    if (currentLevel != null) {
      var lp = '';
      if (currentLevel != 'shared') {
        lp = getLibraryPathForce(file, currentLevel);
        if (OpenFlAssets.exists(lp, type)) return lp;
      }
      lp = getLibraryPathForce(file, 'shared');
      if (OpenFlAssets.exists(lp, type)) return lp;
    }
    return getPreloadPath(file);
  }

  static public function getLibraryPath(file:String, library:String = "preload"):String {
    return if (library == "preload" || library == "default") getPreloadPath(file)
    else getLibraryPathForce(file, library);
  }

  inline static function getLibraryPathForce(file:String, library:String):String {
    return '$library:assets/$library/$file';
  }

  inline public static function getPreloadPath(file:String = ''):String {
    return 'assets/$file';
  }

  inline static public function file(file:String, type:AssetType = TEXT, ?library:String) {
    return getPath(file, type, library);
  }

  inline static public function txt(key:String, ?library:String) {
    return getPath('data/$key.txt', TEXT, library);
  }

  inline static public function xml(key:String, ?library:String) {
    return getPath('data/$key.xml', TEXT, library);
  }

  inline static public function json(key:String, ?library:String) {
    return getPath('data/$key.json', TEXT, library);
  }

  inline static public function lua(key:String, ?library:String) {
    return Main.path + getPath('$key.lua', TEXT, library);
  }

  inline static public function luaAsset(key:String, ?library:String) {
    return getPath('$key.lua', TEXT, library);
  }

  public static function video(key:String) {
    #if MODS_ALLOWED
    var filePath:String = modsVideo(key);
    if (FileSystem.exists(filePath)) return filePath;
    #end
    return 'assets/videos/$key$VIDEO_EXT';
  }

  public static function sound(key:String, ?library:String):Sound {
    return returnSound('sounds', key, library);
  }

  inline public static function soundRandom(key:String, min:Int, max:Int, ?library:String) {
    return sound(key + FlxG.random.int(min, max), library);
  }

  inline public static function music(key:String, ?library:String):Sound {
    return returnSound('music', key, library);
  }

  inline public static function voices(song:String):Any {
    var songKey = '${formatToSongPath(song)}/Voices';
    return returnSound('songs', songKey);
  }

  inline public static function inst(song:String):Any {
    var songKey = '${formatToSongPath(song)}/Inst';
    return returnSound('songs', songKey);
  }

  inline public static function image(key:String, ?library:String):FlxGraphic {
    return returnGraphic(key, library);
  }

  static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String {
    #if MODS_ALLOWED
    if (!ignoreMods && FileSystem.exists(modFolders(key))) {
      return File.getContent(modFolders(key));
    }
    if (FileSystem.exists(SUtil.getPath() + getPreloadPath(key))) {
      return File.getContent(SUtil.getPath() + getPreloadPath(key));
    }
    if (currentLevel != null) {
      var lvlPath:String = '';
      if (currentLevel != 'shared') {
        lvlPath = SUtil.getPath() + getLibraryPathForce(key, currentLevel);
        if (FileSystem.exists(lvlPath)) return File.getContent(lvlPath);
      }
      lvlPath = SUtil.getPath() + getLibraryPathForce(key, 'shared');
      if (FileSystem.exists(lvlPath)) return File.getContent(lvlPath);
    }
    #end
    return Assets.getText(getPath(key, TEXT));
  }

  inline static public function font(key:String) {
    #if MODS_ALLOWED
    var fpath:String = modsFont(key);
    if (FileSystem.exists(fpath)) return fpath;
    #end
    return SUtil.getPath() + 'assets/fonts/$key';
  }

  inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String) {
    #if MODS_ALLOWED
    if (FileSystem.exists(mods(currentModDirectory + '/' + key)) || FileSystem.exists(mods(key))) {
      return true;
    }
    #end
    return OpenFlAssets.exists(getPath(key, type));
  }

  inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames {
    #if MODS_ALLOWED
    var imageLoaded = returnGraphic(key);
    var xmlExists = FileSystem.exists(modsXml(key));
    return FlxAtlasFrames.fromSparrow(imageLoaded, xmlExists ? File.getContent(modsXml(key)) : file('images/$key.xml', library));
    #else
    return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
    #end
  }

  inline static public function getPackerAtlas(key:String, ?library:String) {
    #if MODS_ALLOWED
    var imageLoaded = returnGraphic(key);
    var txtExists = FileSystem.exists(modsTxt(key));
    return FlxAtlasFrames.fromSpriteSheetPacker(imageLoaded, txtExists ? File.getContent(modsTxt(key)) : file('images/$key.txt', library));
    #else
    return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
    #end
  }

  inline static public function formatToSongPath(path:String) {
    return path.toLowerCase().replace(' ', '-');
  }

  public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
  public static function returnGraphic(key:String, ?library:String):FlxGraphic {
    #if MODS_ALLOWED
    var modKey = modsImages(key);
    if (FileSystem.exists(modKey)) {
      if (!currentTrackedAssets.exists(modKey)) {
        var bmp = BitmapData.fromFile(modKey);
        var gfx = FlxGraphic.fromBitmapData(bmp, false, modKey);
        gfx.persist = true;
        currentTrackedAssets.set(modKey, gfx);
      }
      localTrackedAssets.push(modKey);
      return currentTrackedAssets.get(modKey);
    }
    #end
    var path = getPath('images/$key.png', IMAGE, library);
    if (OpenFlAssets.exists(path, IMAGE)) {
      if (!currentTrackedAssets.exists(path)) {
        var gfx = FlxG.bitmap.add(path, false, path);
        gfx.persist = true;
        currentTrackedAssets.set(path, gfx);
      }
      localTrackedAssets.push(path);
      return currentTrackedAssets.get(path);
    }
    trace('Missing image: $key'); return null;
  }

  public static var currentTrackedSounds:Map<String, Sound> = [];
  public static function returnSound(path:String, key:String, ?library:String):Sound {
    #if MODS_ALLOWED
    var fpath = modsSounds(path, key);
    if (FileSystem.exists(fpath)) {
      if (!currentTrackedSounds.exists(fpath)) {
        currentTrackedSounds.set(fpath, Sound.fromFile(fpath));
      }
      localTrackedAssets.push(key);
      return currentTrackedSounds.get(fpath);
    }
    #end
    var full = SUtil.getPath() + getPath('$path/$key.$SOUND_EXT', SOUND, library);
    full = full.substring(full.indexOf(':') + 1);
    if (!currentTrackedSounds.exists(full)) {
      currentTrackedSounds.set(full, Sound.fromFile(full));
    }
    localTrackedAssets.push(full);
    return currentTrackedSounds.get(full);
  }
}
