import 'dart:math';
import 'package:flame/events.dart'; 
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';

class FlappyGame extends FlameGame with TapCallbacks {
  // Variabel Aset
  Sprite? backgroundSprite;
  Sprite? pipeSprite;
  Sprite? birdSprite;

  // Variabel Burung/Roket
  double birdY = 300;
  double velocity = 0;
  final double gravity = 900;
  final double jumpforce = -350;

  // Variabel Pipa
  late double pipeX;
  double pipeGap = 220; // Agak lebar agar roket muat
  double pipeHeight = 200;

  // Status Game
  int score = 0;
  bool gameOver = false;

  @override
  Future<void> onLoad() async {
    pipeX = size.x;
    
    try {
      // Memuat semua gambar
      backgroundSprite = await loadSprite('background.png');
      pipeSprite = await loadSprite('nazii.png');
      birdSprite = await loadSprite('rocket.png');
      print("Semua aset berhasil dimuat!");
    } catch (e) {
      print("Gagal memuat aset: $e. Pastikan file ada di assets/images/");
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    if (gameOver) return;

    // Logika Jatuh
    velocity += gravity * dt; 
    birdY += velocity * dt;
    
    // Gerakan Pipa
    pipeX -= 200 * dt;

    // Reset Pipa & Hitung Skor
    if (pipeX < -80) {
      pipeX = size.x;
      pipeHeight = Random().nextDouble() * (size.y - pipeGap - 100) + 50;
      score++;
    }

    // Cek Batas Atas/Bawah Layar
    if (birdY < 0 || birdY > size.y - 30) {
      triggerGameOver();
    }

    // Cek Tabrakan Pipa (Disesuaikan dengan ukuran roket)
    if (pipeX < 100 && pipeX + 80 > 40) {
      if (birdY < pipeHeight || birdY + 25 > pipeHeight + pipeGap) {
        triggerGameOver();
      }
    }
  }

  void triggerGameOver() {
    gameOver = true;
    // Di sini kamu bisa tambahkan FlameAudio.play('scream.mp3') nanti
  }

  @override
  void render(Canvas canvas) {
    // 1. RENDER BACKGROUND UTAMA
    if (backgroundSprite != null) {
      backgroundSprite!.render(
        canvas, 
        size: size, 
        overridePaint: Paint()..filterQuality = FilterQuality.none
      );
    }

    // 2. RENDER OBJEK GAME (Hanya muncul jika tidak Jumpscare/GameOver)
    if (!gameOver) {
      // Render Pipa
      if (pipeSprite != null) {
        double pipeWidth = 80;
        double logoHeight = 80;

        // Pipa Atas
        pipeSprite!.render(canvas, position: Vector2(pipeX, pipeHeight - logoHeight), size: Vector2(pipeWidth, logoHeight));
        canvas.drawRect(Rect.fromLTWH(pipeX, 0, pipeWidth, pipeHeight - logoHeight), Paint()..color = Colors.red.withOpacity(0.8));

        // Pipa Bawah
        pipeSprite!.render(canvas, position: Vector2(pipeX, pipeHeight + pipeGap), size: Vector2(pipeWidth, logoHeight));
        canvas.drawRect(Rect.fromLTWH(pipeX, pipeHeight + pipeGap + logoHeight, pipeWidth, size.y), Paint()..color = Colors.red.withOpacity(0.8));
      }

      // Render Roket
      if (birdSprite != null) {
        birdSprite!.render(
          canvas,
          position: Vector2(40, birdY),
          size: Vector2(60, 30),
          overridePaint: Paint()..filterQuality = FilterQuality.none
        );
      }
    }

    // 3. RENDER JUMPSCARE SAAT GAME OVER
    if (gameOver) {
      if (backgroundSprite != null) {
        // Efek Jumpscare: Zoom ke wajah dan kasih filter merah
        backgroundSprite!.render(
          canvas,
          position: Vector2(-size.x * 0.5, -size.y * 0.2), // Fokus ke tengah gambar
          size: size * 2.5, // Perbesar gambar agar wajah memenuhi layar
          overridePaint: Paint()
            ..colorFilter = const ColorFilter.mode(Colors.redAccent, BlendMode.modulate)
            ..filterQuality = FilterQuality.none,
        );
      }

      // Overlay Hitam Transparan agar teks terbaca
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = Colors.black26);

      _drawText(canvas, "MATI KAU!", size.x / 2 - 80, size.y / 2 - 50, fontSize: 40, color: Colors.white);
      _drawText(canvas, "Tap to Restart", size.x / 2 - 90, size.y / 2 + 20, fontSize: 24, color: Colors.yellowAccent);
    }

    // Skor (Hanya muncul saat main)
    if (!gameOver) {
      _drawText(canvas, 'Score: $score', 20, 40, fontSize: 24, color: Colors.white);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (gameOver) {
      restartGame();
    } else {
      velocity = jumpforce;
    }
  }

  void restartGame() {
    birdY = 300;
    velocity = 0;
    pipeX = size.x;
    score = 0;
    gameOver = false;
  }

  void _drawText(Canvas canvas, String text, double x, double y, {double fontSize = 24, Color color = Colors.white}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontWeight: FontWeight.bold, backgroundColor: Colors.black38),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(x, y));
  }
}