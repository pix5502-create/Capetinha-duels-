import sys
import random
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtGui import *

class AnimeInterface(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("✨ Anime Grab System ✨")
        self.setGeometry(100, 100, 500, 450)
        self.setWindowFlags(Qt.FramelessWindowHint)
        self.setAttribute(Qt.WA_TranslucentBackground)
        
        self.speed = 0
        self.is_grabbing = False
        self.is_jumping = False
        self.is_minimized = False
        self.drag_pos = None
        self.saved_geometry = None
        
        # Widget central
        central = QWidget()
        central.setStyleSheet("""
            QWidget {
                background-color: #1a1a2e;
                border-radius: 20px;
                border: 3px solid #ff6b9d;
            }
        """)
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)
        layout.setContentsMargins(20, 20, 20, 20)
        
        # Barra de título
        title_bar = QWidget()
        title_bar.setStyleSheet("background-color: #16213e; border-radius: 15px;")
        title_layout = QHBoxLayout(title_bar)
        title_layout.setContentsMargins(10, 5, 10, 5)
        
        titulo = QLabel("⚡ NEO GRABBER ⚡")
        titulo.setStyleSheet("color: #ff6b9d; font-size: 18px; font-weight: bold; font-family: 'Comic Sans MS';")
        title_layout.addWidget(titulo)
        title_layout.addStretch()
        
        # Botão minimizar
        self.minimize_btn = QPushButton("➖")
        self.minimize_btn.setStyleSheet("""
            QPushButton {
                background-color: #2a2a4a;
                color: white;
                font-size: 20px;
                font-weight: bold;
                padding: 5px 15px;
                border-radius: 10px;
                border: 2px solid #ffd700;
                min-width: 40px;
                min-height: 40px;
            }
            QPushButton:hover {
                background-color: #ffd700;
                color: #1a1a2e;
            }
        """)
        self.minimize_btn.clicked.connect(self.toggle_minimize)
        title_layout.addWidget(self.minimize_btn)
        
        # Botão fechar
        close_btn = QPushButton("✕")
        close_btn.setStyleSheet("""
            QPushButton {
                background-color: #2a2a4a;
                color: white;
                font-size: 20px;
                font-weight: bold;
                padding: 5px 15px;
                border-radius: 10px;
                border: 2px solid #ff2e63;
                min-width: 40px;
                min-height: 40px;
            }
            QPushButton:hover {
                background-color: #ff2e63;
                color: white;
            }
        """)
        close_btn.clicked.connect(self.close)
        title_layout.addWidget(close_btn)
        
        layout.addWidget(title_bar)
        
        # Personagem
        self.personagem = QLabel("🧚‍♀️")
        self.personagem.setStyleSheet("font-size: 80px; background-color: #16213e; border-radius: 50px; padding: 20px;")
        self.personagem.setAlignment(Qt.AlignCenter)
        layout.addWidget(self.personagem)
        
        # Status
        self.status_label = QLabel("📡 Modo: Aguardando")
        self.status_label.setStyleSheet("color: #00d2ff; font-size: 16px;")
        self.status_label.setAlignment(Qt.AlignCenter)
        layout.addWidget(self.status_label)
        
        # Botão Alto Grab
        self.grab_btn = QPushButton("🤖 ALTO GRAB")
        self.grab_btn.setStyleSheet("""
            QPushButton {
                background-color: #ff6b9d;
                color: white;
                font-size: 20px;
                font-weight: bold;
                padding: 15px;
                border-radius: 25px;
                border: 3px solid #ff2e63;
            }
            QPushButton:hover {
                background-color: #ff2e63;
            }
        """)
        self.grab_btn.clicked.connect(self.toggle_grab)
        layout.addWidget(self.grab_btn)
        
        # Controle de velocidade
        layout_speed = QHBoxLayout()
        label_speed = QLabel("🚀 Speed:")
        label_speed.setStyleSheet("color: white; font-size: 14px;")
        layout_speed.addWidget(label_speed)
        
        self.speed_slider = QSlider(Qt.Horizontal)
        self.speed_slider.setRange(0, 60)
        self.speed_slider.setValue(0)
        self.speed_slider.setStyleSheet("""
            QSlider::groove:horizontal {
                height: 10px;
                background: #2a2a4a;
                border-radius: 5px;
            }
            QSlider::handle:horizontal {
                background: #ff6b9d;
                width: 20px;
                margin: -5px 0;
                border-radius: 10px;
            }
            QSlider::handle:hover {
                background: #ffd700;
            }
        """)
        self.speed_slider.valueChanged.connect(self.update_speed)
        layout_speed.addWidget(self.speed_slider)
        
        self.speed_label = QLabel("0")
        self.speed_label.setStyleSheet("color: #ffd700; font-size: 18px; font-weight: bold;")
        layout_speed.addWidget(self.speed_label)
        layout.addLayout(layout_speed)
        
        # Botão Pular/Voar
        self.jump_btn = QPushButton("🦋 PULAR & VOAR")
        self.jump_btn.setStyleSheet("""
            QPushButton {
                background-color: #6c5ce7;
                color: white;
                font-size: 18px;
                font-weight: bold;
                padding: 12px;
                border-radius: 25px;
                border: 3px solid #a29bfe;
            }
            QPushButton:hover {
                background-color: #a29bfe;
            }
        """)
        self.jump_btn.clicked.connect(self.jump_fly)
        layout.addWidget(self.jump_btn)
        
        # Timers
        self.timer = QTimer()
        self.timer.timeout.connect(self.animate)
        self.timer.start(100)
        
        self.fly_timer = QTimer()
        self.fly_timer.timeout.connect(self.fly_effect)
        
    def toggle_minimize(self):
        if not self.is_minimized:
            # Minimizar
            self.saved_geometry = self.geometry()
            self.setGeometry(100, 100, 200, 80)
            
            self.minimize_btn.setText("⏺")
            self.minimize_btn.setStyleSheet("""
                QPushButton {
                    background-color: #ffd700;
                    color: #1a1a2e;
                    font-size: 20px;
                    font-weight: bold;
                    padding: 5px 15px;
                    border-radius: 10px;
                    border: 2px solid #ffd700;
                    min-width: 40px;
                    min-height: 40px;
                }
                QPushButton:hover {
                    background-color: #ff6b9d;
                    color: white;
                }
            """)
            self.is_minimized = True
            
            # Esconder widgets
            for i in range(1, self.centralWidget().layout().count()):
                item = self.centralWidget().layout().itemAt(i)
                if item and item.widget():
                    widget = item.widget()
                    if widget and widget != self.personagem:
                        widget.hide()
            
            self.personagem.setStyleSheet("font-size: 40px; background-color: #16213e; border-radius: 20px; padding: 5px;")
            self.personagem.setText("🧚")
            
        else:
            # Restaurar
            if self.saved_geometry:
                self.setGeometry(self.saved_geometry)
            
            self.minimize_btn.setText("➖")
            self.minimize_btn.setStyleSheet("""
                QPushButton {
                    background-color: #2a2a4a;
                    color: white;
                    font-size: 20px;
                    font-weight: bold;
                    padding: 5px 15px;
                    border-radius: 10px;
                    border: 2px solid #ffd700;
                    min-width: 40px;
                    min-height: 40px;
                }
                QPushButton:hover {
                    background-color: #ffd700;
                    color: #1a1a2e;
                }
            """)
            self.is_minimized = False
            
            # Mostrar widgets
            for i in range(1, self.centralWidget().layout().count()):
                item = self.centralWidget().layout().itemAt(i)
                if item and item.widget():
                    widget = item.widget()
                    if widget:
                        widget.show()
            
            self.personagem.setStyleSheet("font-size: 80px; background-color: #16213e; border-radius: 50px; padding: 20px;")
            if self.is_grabbing:
                self.personagem.setText("🦾")
            else:
                self.personagem.setText("🧚‍♀️")
    
    def toggle_grab(self):
        self.is_grabbing = not self.is_grabbing
        if self.is_grabbing:
            self.grab_btn.setText("🛑 PARAR GRAB")
            self.status_label.setText("🎯 GRAB ATIVADO!")
            self.personagem.setText("🦾")
        else:
            self.grab_btn.setText("🤖 ALTO GRAB")
            self.status_label.setText("📡 Modo: Aguardando")
            self.personagem.setText("🧚‍♀️")
    
    def update_speed(self, value):
        self.speed = value
        self.speed_label.setText(str(value))
        self.status_label.setText(f"⚡ Velocidade: {value}/60")
        
        if value > 40:
            self.personagem.setStyleSheet(f"font-size: {80 + value}px; background-color: #16213e; border-radius: 50px; padding: 20px; border: 3px solid #ff6b9d;")
    
    def jump_fly(self):
        if self.is_minimized:
            return
            
        self.is_jumping = True
        self.status_label.setText("🦋 VOANDO!!!")
        self.personagem.setText("🌈")
        
        for i in range(5):
            QTimer.singleShot(i * 100, lambda: self.personagem.move(
                self.personagem.x(),
                self.personagem.y() - 10
            ))
        
        QTimer.singleShot(1000, self.stop_jump)
        self.fly_timer.start(50)
    
    def stop_jump(self):
        self.is_jumping = False
        if self.is_grabbing:
            self.personagem.setText("🦾")
        else:
            self.personagem.setText("🧚‍♀️")
        self.status_label.setText("📡 Modo: Aguardando")
        self.fly_timer.stop()
    
    def fly_effect(self):
        if self.is_grabbing:
            self.personagem.setText("🦾✨")
        else:
            self.personagem.setText("🌈✨")
        
        self.personagem.move(
            self.personagem.x() + random.randint(-5, 5),
            self.personagem.y() + random.randint(-5, 5)
        )
    
    def animate(self):
        if self.speed > 0 and self.is_grabbing and not self.is_minimized:
            colors = ["#ff6b9d", "#ff2e63", "#ffd700", "#6c5ce7"]
            self.grab_btn.setStyleSheet(f"""
                QPushButton {{
                    background-color: {random.choice(colors)};
                    color: white;
                    font-size: 20px;
                    font-weight: bold;
                    padding: 15px;
                    border-radius: 25px;
                    border: 3px solid #ff2e63;
                }}
            """)
    
    def mousePressEvent(self, event):
        if event.button() == Qt.LeftButton:
            self.drag_pos = event.globalPos()
    
    def mouseMoveEvent(self, event):
        if self.drag_pos is not None:
            delta = event.globalPos() - self.drag_pos
            self.move(self.x() + delta.x(), self.y() + delta.y())
            self.drag_pos = event.globalPos()
    
    def mouseReleaseEvent(self, event):
        self.drag_pos = None

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = AnimeInterface()
    window.show()
    sys.exit(app.exec_())
