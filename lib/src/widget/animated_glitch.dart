import 'dart:math';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class AnimatedGlitch extends StatefulWidget{
  /// The color channel level.
  final double colorChannelLevel;

  /// The distortion level.
  final double distortionLevel;

  /// The amount of glitch.
  final double glitchAmount;

  /// The speed of the glitch.
  final double speed;

  /// The chance of the glitch.
  final int chance;

  /// Whether to display the distortions.
  final bool showDistortions;

  /// Whether to display the color channels.
  final bool showColorChannels;

  /// The widget to display.
  final Widget child;

  /// The time increment.
  /// You may think of it as a second speed value but with more precision.
  final double speedStep;

  /// Whether the glitch is active.
  final bool isActive;

  /// Whether color channels are shifted by Y.
  final bool isColorsShiftedVertically;

  /// Whether color channels are shifted by x.
  final bool isColorsShiftedHorizontally;

  const AnimatedGlitch({
    super.key,
    this.chance = 50,
    this.speed = 1,
    this.distortionLevel = 0.035,
    this.colorChannelLevel = 0.023,
    this.showColorChannels = true,
    this.showDistortions = true,
    this.glitchAmount = 3,
    this.speedStep = 0.0042,
    this.isActive = true,
    this.isColorsShiftedVertically = false,
    this.isColorsShiftedHorizontally = true,
    required this.child
  })  : assert(glitchAmount <= 10,'glitchAmount must be less than or equal to 10'),
        assert(speed >= 0 && speed <= 1, 'speed must be between 0 and 1'),
        assert(chance >= 0 && chance <= 100,'chance must be between 0 and 100'),
        assert(distortionLevel >= 0 && distortionLevel <= 1,'distortionLevel must be between 0 and 1'),
        assert(colorChannelLevel >= 0 && colorChannelLevel <= 1,'colorChannelLevel must be between 0 and 100');

  @override
  State<StatefulWidget> createState() => AnimatedGlitchState();
}

class AnimatedGlitchState extends State<AnimatedGlitch> {

  late final Ticker ticker;
  double time=0.0;

  @override
  void initState() {
    super.initState();
    ticker=Ticker((duration)=>mounted ? setState(
      ()=>time+=min<double>(duration.inMilliseconds.toDouble(),widget.speedStep)
    ) : false);
    if(widget.isActive){
      ticker.start();
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedGlitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if(oldWidget.isActive != widget.isActive){
      widget.isActive ? ticker.start() : ticker.stop();
    };
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ShaderBuilder(
    (context,shader,child)=>AnimatedSampler(
      (image,size,canvas){
        shader
          ..setFloat(0, widget.isActive ? time : 0.0)
          // uResolution x
          ..setFloat(1, size.width)
          // uResolution y
          ..setFloat(2, size.height)
          // uDistortionLevel
          ..setFloat(3, widget.distortionLevel)
          // uColorChannelLevel
          ..setFloat(4, widget.colorChannelLevel)
          // uSpeed
          ..setFloat(5, widget.speed)
          // uChance
          ..setFloat(6, widget.chance.toDouble())
          // uShowDistortion
          ..setFloat(7, widget.showDistortions ? 1.0 : 0.0)
          // uShowColorChannel
          ..setFloat(8, widget.showColorChannels ? 1.0 : 0.0)
          // uShiftColorChannelsY
          ..setFloat(9, widget.isColorsShiftedVertically ? 1.0 : 0.0)
          // uShiftColorChannelsX
          ..setFloat(10, widget.isColorsShiftedHorizontally ? 1.0 : 0.0)
          // uGlitchAmount
          ..setFloat(11, widget.glitchAmount)
          // uChannel0
          ..setImageSampler(0, image);
        canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
      }, 
      child: child!,
    ),
    assetKey: 'packages/animated_glitch/shader/glitch.frag',
    child: widget.child,
  );

}