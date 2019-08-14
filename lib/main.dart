import 'dart:math';

import 'package:flutter/material.dart';
import 'package:music_player/songs.dart';
import 'package:music_player/theme.dart';
import 'package:fluttery/gestures.dart';
import 'package:fluttery_audio/fluttery_audio.dart';

import 'bottom_controls.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter播放器(wuyou)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return AudioPlaylist(
      playlist: demoPlayList.songs.map((DemoSong song) {
        return song.audioUrl;
      }).toList(growable: false),
      playbackState: PlaybackState.paused,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: const Color(0xFFDDDDDD),
                ),
                onPressed: () {}),
            title: Text(''),
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: const Color(0xFFDDDDDD),
                  ),
                  onPressed: () {}),
            ],
          ),
          body: Column(
            children: <Widget>[
              //Seek bar
              Expanded(
                child: AudioPlaylistComponent(
                  playlistBuilder:
                      (BuildContext context, Playlist playList, Widget child) {
                    String albumArtUrl =
                        demoPlayList.songs[playList.activeIndex].albumArtUrl;
                    return AudioRadialSeekBar(
                      albumArtUrl: albumArtUrl,
                    );
                  },
                ),
              ),
              //Visualizer
              Container(
                width: double.infinity,
                height: 125,
                child: Visualizer(
                  builder: (BuildContext context, List<int> fft) {
                    return CustomPaint(
                      painter: VisualizerPainter(
                        fft: fft,
                        height: 125.0,
                        color: accentColor,
                      ),
                    );
                  },
                ),
              ),
              //Song title,artist name, and controls
              BottomControls()
            ],
          )),
    );
  }
}

class AudioRadialSeekBar extends StatefulWidget {
  final String albumArtUrl;

  AudioRadialSeekBar({this.albumArtUrl});

  @override
  _AudioRadialSeekBarState createState() => _AudioRadialSeekBarState();
}

class _AudioRadialSeekBarState extends State<AudioRadialSeekBar> {
  double _seekPercent;

  @override
  Widget build(BuildContext context) {
    return AudioComponent(
      updateMe: [
        WatchableAudioProperties.audioSeeking,
        WatchableAudioProperties.audioPlayhead
      ],
      playerBuilder: (BuildContext context, AudioPlayer player, Widget child) {
        double playbackProgress = 0.0;
        if (player.audioLength != null && player.position != null) {
          playbackProgress = player.position.inMilliseconds /
              player.audioLength.inMilliseconds;
        }
        _seekPercent = player.isSeeking ? _seekPercent : null;
        return RadialSeekBar(
            progress: playbackProgress,
            seekPercent: _seekPercent,
            onSeekRequested: (double seekPercent) {
              setState(() {
                _seekPercent = seekPercent;
                final seekMills =
                    (player.audioLength.inMilliseconds * seekPercent).round();
                player.seek(Duration(milliseconds: seekMills));
              });
            },
            child: Container(
              color: accentColor,
              child: Image.network(
                widget.albumArtUrl,
                fit: BoxFit.cover,
              ),
            ));
      },
    );
  }
}

class RadialSeekBar extends StatefulWidget {
  final double seekPercent;
  final double progress;
  final Function(double) onSeekRequested;
  final Widget child;

  RadialSeekBar(
      {this.seekPercent = 0.0,
      this.progress = 0.0,
      this.onSeekRequested,
      this.child});

  @override
  _RadialSeekBarState createState() => _RadialSeekBarState();
}

class _RadialSeekBarState extends State<RadialSeekBar> {
  double _progress = 0.0;
  PolarCoord _startDragCoord;
  double _startDragPercent;
  double _currentDragPercent;

  @override
  void initState() {
    super.initState();
    _progress = widget.progress;
  }

  @override
  void didUpdateWidget(RadialSeekBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _progress = widget.progress;
  }

  void _onDragStart(PolarCoord p) {
    _startDragCoord = p;
    _startDragPercent = _progress;
  }

  void _onDragUpdate(PolarCoord p) {
    final dragAngle = p.angle - _startDragCoord.angle;
    final dragPercent = dragAngle / (2 * pi);

    setState(() {
      _currentDragPercent = (_startDragPercent + dragPercent) % 1.0;
    });
  }

  void _onDragEnd() {
    if (widget.onSeekRequested != null) {
      widget.onSeekRequested(_currentDragPercent);
    }
    setState(() {
      _progress = _currentDragPercent;
      _currentDragPercent = null;
      _startDragCoord = null;
      _startDragPercent = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    double thumbPosition = _progress;
    if (_currentDragPercent != null) {
      thumbPosition = _currentDragPercent;
    } else if (widget.seekPercent != null) {
      thumbPosition = widget.seekPercent;
    }
    return RadialDragGestureDetector(
      onRadialDragStart: _onDragStart,
      onRadialDragUpdate: _onDragUpdate,
      onRadialDragEnd: _onDragEnd,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: 200,
            height: 200,
            child: RadialProgressBar(
                progressPercent: _progress,
                thumbPosition: thumbPosition,
                innerPadding: const EdgeInsets.all(10.0),
                trackColor: const Color(0xFFDDDDDD),
                progressColor: accentColor,
                thumbColor: lightAccentColor,
                child: ClipOval(
                  clipper: CircleClipper(),
                  child: widget.child,
                )),
          ),
        ),
      ),
    );
  }
}

class RadialProgressBar extends StatefulWidget {
  final double trackWidth;
  final Color trackColor;
  final double progressPercent;
  final double progressWidth;
  final Color progressColor;
  final Color thumbColor;
  final double thumbSize;
  final double thumbPosition;
  final EdgeInsets outerPadding;
  final EdgeInsets innerPadding;
  final Widget child;

  RadialProgressBar(
      {this.trackWidth = 3.0,
      this.trackColor,
      this.progressWidth = 5.0,
      this.progressColor,
      this.progressPercent = 0.0,
      this.thumbColor,
      this.thumbSize = 10.0,
      this.thumbPosition = 0.0,
      this.outerPadding = const EdgeInsets.all(0.0),
      this.innerPadding = const EdgeInsets.all(0.0),
      this.child});

  @override
  _RadialProgressBarState createState() => _RadialProgressBarState();
}

class _RadialProgressBarState extends State<RadialProgressBar> {
  EdgeInsets _insetsForPainter() {
    final outerThickness =
        max(widget.trackWidth, max(widget.progressWidth, widget.thumbSize));
    return EdgeInsets.all(outerThickness);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.outerPadding,
      child: CustomPaint(
        foregroundPainter: RadialSeekBarPainter(
          trackWidth: widget.trackWidth,
          thumbColor: widget.thumbColor,
          progressWidth: widget.progressWidth,
          progressColor: widget.progressColor,
          progressPercent: widget.progressPercent,
          thumbSize: widget.thumbSize,
          trackColor: widget.trackColor,
          thumbPosition: widget.thumbPosition,
        ),
        child: Padding(
          padding: _insetsForPainter() + widget.innerPadding,
          child: widget.child,
        ),
      ),
    );
  }
}

class VisualizerPainter extends CustomPainter {
  final List<int> fft;
  final double height;
  final Color color;
  final Paint wavePainter;

  VisualizerPainter({this.fft, this.height, this.color})
      : wavePainter = new Paint()
          ..color = color.withOpacity(0.75)
          ..style = PaintingStyle.fill;

  List<int> _createHistogram(List<int> samples, int bucketCount,
      [int start, int end]) {
    if (start == end) {
      return const [];
    }
    start = start ?? 0;
    end = end ?? samples.length - 1;
    final sampleCount = end - start + 1;
    final samplesPerBucket = (sampleCount / bucketCount).floor();
    if (samplesPerBucket == 0) {
      return const [];
    }
    final actualSampleCount = sampleCount - (sampleCount % samplesPerBucket);
    List<int> histogram = List<int>.filled(bucketCount, 0);

    for (int i = start; i <= start + actualSampleCount; ++i) {
      if ((i - start) % 2 == 1) {
        continue;
      }
      int bucketIndex = ((i - start) / samplesPerBucket).floor();
      histogram[bucketIndex] += samples[i];
    }

    for (int i = 0; i < histogram.length; ++i) {
      histogram[i] = (histogram[i] / samplesPerBucket).abs().round();
    }
    return histogram;
  }

  void _renderWaves(Canvas canvas, Size size) {
    final histogramLow = _createHistogram(fft, 15, 2, (fft.length / 4).floor());
    final histogramHigh = _createHistogram(
        fft, 15, (fft.length / 4).ceil(), (fft.length / 2).floor());

    _renderHistogram(canvas, size, histogramLow);
    _renderHistogram(canvas, size, histogramHigh);
  }

  void _renderHistogram(Canvas canvas, Size size, List<int> histogram) {
    if (histogram.length == 0) return;
    final pointsToGraph = histogram.length;
    final widthPerSample = (size.width / (pointsToGraph - 2)).floor();

    final points = List<double>.filled(pointsToGraph * 4, 0.0);

    for (int i = 0; i < histogram.length - 1; ++i) {
      points[i * 4] = (i * widthPerSample).toDouble();
      points[i * 4 + 1] = size.height - histogram[i].toDouble();
      points[i * 4 + 2] = ((i + 1) * widthPerSample).toDouble();
      points[i * 4 + 3] = size.height - histogram[i + 1].toDouble();
    }
    Path path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(points[0], points[1]);
    for (int i = 2; i < points.length - 4; i += 2) {
      path.cubicTo(points[i - 2] + 10.0, points[i - 1], points[i] - 10.0,
          points[i + 1], points[i], points[i + 1]);
    }
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, wavePainter);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _renderWaves(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class RadialSeekBarPainter extends CustomPainter {
  final double trackWidth;
  final Paint trackPaint;
  final double progressPercent;
  final double progressWidth;
  final Paint progressPaint;
  final Paint thumbPaint;
  final double thumbSize;
  final double thumbPosition;

  RadialSeekBarPainter({
    @required this.trackWidth,
    @required trackColor,
    @required this.progressWidth,
    @required progressColor,
    @required this.progressPercent,
    @required thumbColor,
    @required this.thumbSize,
    @required this.thumbPosition,
  })  : trackPaint = Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = trackWidth,
        progressPaint = Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = progressWidth
          ..strokeCap = StrokeCap.round,
        thumbPaint = Paint()
          ..color = thumbColor
          ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final outerThickness = max(trackWidth, max(progressWidth, thumbSize));
    Size constrainedSize =
        Size(size.width - outerThickness, size.height - outerThickness);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(constrainedSize.width, constrainedSize.height) / 2;
    //paint track
    canvas.drawCircle(center, radius, trackPaint);
    //paint progress
    final progressAngle = 2 * pi * progressPercent;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        progressAngle, false, progressPaint);
    //Paint thumb
    final thumbAngle = 2 * pi * thumbPosition - pi / 2;
    final thumbX = cos(thumbAngle) * radius;
    final thumbY = sin(thumbAngle) * radius;
    final thumbCenter = Offset(thumbX, thumbY) + center;
    final thumbRadius = thumbSize / 2;
    canvas.drawCircle(thumbCenter, thumbRadius, thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
