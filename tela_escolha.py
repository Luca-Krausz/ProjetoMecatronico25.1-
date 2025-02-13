from kivy.uix.screenmanager import Screen
from kivy.uix.image import Image
from kivy.uix.button import Button

class TelaEscolha(Screen):
    def __init__(self, **kwargs):
        super(TelaEscolha, self).__init__(**kwargs)
        
        # Imagem de fundo
        self.bg = Image(
            source='imagens\Escolha das opções.jpg',
            allow_stretch=True,
            keep_ratio=False
        )
        self.add_widget(self.bg)

        # Botão "Manual"
        self.btn_manual = Button(
            text="Manual",
            size_hint=(None, None),
            size=(130, 45),
            pos=(780, 400),
            background_normal='',
            background_down='',
            # Use RGBA com alpha > 0 para enxergar o botão (ex: 30% opacidade)
            background_color=(1, 0, 0, 0.3)  
            # Para deixar invisível depois, basta colocar alpha=0 ou remover esta linha.
        )
        self.btn_manual.bind(on_release=self.on_button_press)
        self.add_widget(self.btn_manual)

        # Botão "Automático"
        self.btn_automatico = Button(
            text="Automático",
            size_hint=(None, None),
            size=(130, 45),
            pos=(780, 290),
            background_normal='',
            background_down='',
            background_color=(0, 1, 0, 0.3)
        )
        self.btn_automatico.bind(on_release=self.on_button_press)
        self.add_widget(self.btn_automatico)

        # Botão "Histórico"
        self.btn_historico = Button(
            text="Histórico",
            size_hint=(None, None),
            size=(130, 45),
            pos=(780, 180),
            background_normal='',
            background_down='',
            background_color=(0, 0, 1, 0.3)
        )
        self.btn_historico.bind(on_release=self.on_button_press)
        self.add_widget(self.btn_historico)

    def on_button_press(self, instance):
        # Sempre que um botão for clicado, imprime o texto dele
        print(f"Botão clicado: {instance.text}")
