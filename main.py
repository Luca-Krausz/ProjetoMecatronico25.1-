import kivy
kivy.require('2.0.0')  # Garante a versão mínima do Kivy

from kivy.app import App
from kivy.uix.screenmanager import ScreenManager
from kivy.core.window import Window

from tela_inicial import TelaInicial
from tela_escolha import TelaEscolha

# Define o tamanho fixo da janela: 1020x600
Window.size = (1020, 600)

class GerenciadorTelas(ScreenManager):
    pass

class IHMApp(App):
    def build(self):
        sm = GerenciadorTelas()
        sm.add_widget(TelaInicial(name='tela_inicial'))
        sm.add_widget(TelaEscolha(name='tela_escolha'))
        # Inicia na tela inicial
        sm.current = 'tela_inicial'
        return sm

if __name__ == '__main__':
    IHMApp().run()
