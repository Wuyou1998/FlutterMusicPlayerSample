import 'package:flutter/material.dart';

final DemoPlayList demoPlayList = DemoPlayList(
  songs: [
    new DemoSong(
      audioUrl: 'https://webfs.yun.kugou.com/201906021551/138742e4dff13c59a3a3f6d2609861f1/G119/M01/05/0D/F4cBAFxlweSAT9BlAEHWDL3dgeI800.mp3',
      albumArtUrl: 'https://p3fx.kgimg.com/stdmusic/20190216/20190216172238787963.jpg',
      songTitle: '绿色',
      artist: '陈雪凝',
    ),
    new DemoSong(
      audioUrl: 'https://webfs.yun.kugou.com/201906011520/a952b450801e25f318d147d08811ec27/G004/M07/16/01/RA0DAFS5MrWAUl75ADW2E7EymdY160.mp3',
      albumArtUrl: 'https://p3fx.kgimg.com/stdmusic/20160907/20160907185134999419.jpg',
      songTitle: '清明雨上',
      artist: '许嵩',
    ),
    new DemoSong(
      audioUrl: 'https://webfs.yun.kugou.com/201906011523/2ca790622e03b763f9ab6bd8155ea869/G004/M06/04/08/pIYBAFS54SiAMi7PAD8-ejOqpbY010.mp3',
      albumArtUrl: 'https://p3fx.kgimg.com/stdmusic/20150717/20150717132758317021.jpg',
      songTitle: '玫瑰花的葬礼',
      artist: '许嵩',
    ),
    new DemoSong(
      audioUrl: 'https://webfs.yun.kugou.com/201906011529/9d3ed69f08ffd9f7995eb201cfc54a93/G006/M00/14/01/poYBAFS8u2iAclsoAD5mXxPRhCQ530.mp3',
      albumArtUrl: 'https://p3fx.kgimg.com/stdmusic/20150718/20150718121747813493.jpg',
      songTitle: '庐州月',
      artist: '许嵩',
    ),
    new DemoSong(
      audioUrl: 'https://webfs.yun.kugou.com/201906011531/98ea1bc1d4a6c4e0cac8ac3eface82ac/G013/M06/18/1F/TQ0DAFULduKAeKo1AD6j6vdDSIk363.mp3',
      albumArtUrl: 'https://p3fx.kgimg.com/stdmusic/20150714/20150714135002208061.jpg',
      songTitle: '惊鸿一瞥',
      artist: '许嵩 黄龄',
    ),
    new DemoSong(
      audioUrl: 'https://webfs.yun.kugou.com/201906011532/bfd06930238f851e0c6493ea8c9cc642/G010/M01/03/05/Sg0DAFULduSAOPZdAENy71qPqGk400.mp3',
      albumArtUrl: 'https://p3fx.kgimg.com/stdmusic/20150718/20150718181152737845.jpg',
      songTitle: '山水之间',
      artist: '许嵩',
    ),
  ],
);

class DemoPlayList {
  final List<DemoSong> songs;

  DemoPlayList({@required this.songs});
}

class DemoSong {
  final String audioUrl;
  final String albumArtUrl;
  final String songTitle;
  final String artist;

  DemoSong({
    @required this.audioUrl,
    @required this.albumArtUrl,
    @required this.songTitle,
    @required this.artist,
  });
}
