from kivy.uix.screenmanager import Screen
from kivy.uix.image import Image
from kivy.clock import Clock

class TelaInicial(Screen):
    def __init__(self, **kwargs):
        super(TelaInicial, self).__init__(**kwargs)
        
        # Exibe a imagem de fundo
        self.bg = Image(
            source='imagens\Início.jpg',
            allow_stretch=True,
            keep_ratio=False
        )
        self.add_widget(self.bg)

    def on_enter(self):
        """
        Ao entrar na tela, agenda a mudança para a tela de opções em 3 segundos.
        """
        Clock.schedule_once(self.ir_para_tela_escolha, 3)

    def ir_para_tela_escolha(self, *args):
        """
        Troca para a tela de escolha.
        """
        self.manager.current = 'tela_escolha'
