package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxSound;
import Controls;

using StringTools;

class OptionsState extends MusicBeatState
{
	var options:Array<String> = []; // i removed note colors cause it's useless :/ (but the code still on the source)
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;
	public static var instance:OptionsState;

	var optionsLanguage:Array<String> = [];
	
	var pauseMusicC:FlxSound;

	public var resetState:Bool = false;

	function openSelectedSubstate(label:String) {
		switch(label) {
			case 'Controls' | 'Controles':
				openSubState(new options.ControlsSubState());
			case 'Graphics' | 'Gráficos':
				openSubState(new options.GraphicsSettingsSubState());
			case 'Visuals and UI' | 'Visuais e UI':
				openSubState(new options.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.GameplaySettingsSubState());
			case 'Adjust Delay and Combo' | 'Ajustar Delay e Combo':
				LoadingState.loadAndSwitchState(new options.NoteOffsetState());
			case 'Secret Stuff' | 'Segredos Escondidos':
				openSubState(new options.SecretOptionsState());
		}

		if (label == "Gráficos") label = "Graficos";
		CoolUtil.setWindowTitle('${Language.titleWindow[5]}: ' + label);
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		instance = this;

		var shitArray:Array<String> = Language.uiTexts.get('optionsTitles');

		for (option in shitArray)
		{
			optionsLanguage.push(option);
		}
		options = optionsLanguage;

		CoolUtil.setWindowTitle(Language.titleWindow[5]);

		if (MainMenuState.instance.stinkypoopoo)
		{
			options.remove(shitArray[4]);
		}

		if (ClientPrefs.secretActivated)
		{
			options.push(Language.uiTexts.get('secretOptionTitle'));
		}

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xff764ad4;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		for (i in 0...options.length)
		{
			var optionText:Alphabet = new Alphabet(0, 0, options[i], true);
			optionText.screenCenter();
			optionText.y += (100 * (i - (options.length / 2))) + 50;
			grpOptions.add(optionText);
		}

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		if (MainMenuState.instance.stinkypoopoo)
		{
			pauseMusicC = new FlxSound();
			
			if (ClientPrefs.pauseMusic != 'None') {
				pauseMusicC.loadEmbedded(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)), true, true);
			}
				
			pauseMusicC.volume = 0;
			pauseMusicC.play(false, Std.int(pauseMusicC.length / 2));
	
			FlxTween.tween(pauseMusicC, {volume: 0.6}, 0.4, {ease: FlxEase.quintOut});
	
			FlxG.sound.list.add(pauseMusicC);
	
			if (controls.BACK)
			{
				FlxTween.tween(pauseMusicC, {volume: 0}, 0.4, {ease: FlxEase.quintOut});
				new FlxTimer().start(0.4, function(tmr:FlxTimer)
				{
					pauseMusicC.destroy();
				});
			}
		}

		changeSelection();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		CoolUtil.setWindowTitle(Language.titleWindow[5]);
		ClientPrefs.saveSettings();
		if (resetState) FlxG.resetState();
		super.closeSubState();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if (PlayState.instance != null && MainMenuState.instance.stinkypoopoo)
			{
				MusicBeatState.switchState(new PlayState());
			} else {
				MusicBeatState.switchState(new MainMenuState());
				MainMenuState.instance.stinkypoopoo = false;
			}
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(options[curSelected]);
		}
	}
	
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}