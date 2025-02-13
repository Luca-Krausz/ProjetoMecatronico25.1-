import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.widgets import Button
import random
import math

# =============================================================================
# Parâmetros Gerais (unidades: mm)
# =============================================================================
table_width    = 300    # Largura da bancada (mesa)
table_height   = 200    # Altura da bancada
support_width  = 100    # Largura do suporte dos tubetes
support_height = 60     # Altura do suporte dos tubetes

# Para 30 tubetes, usamos:
n_rows = 5     # Número de linhas (dividindo a altura de 60 mm)
n_cols = 6     # Número de colunas (dividindo a largura de 100 mm)

N_meas    = 50   # Número de pontos de medição por borda (para o suporte)
error_std = 2.0  # Desvio-padrão do ruído (mm)

# Parâmetros do becker (cilíndrico)
beaker_radius = 15   # Raio do becker, em mm

# Limites comuns para os dois painéis (mesma escala)
common_xlim = (-20, table_width + 20)
common_ylim = (-20, table_height + 20)

# =============================================================================
# Função de interpolação (já usada para o suporte, se necessário)
# =============================================================================
def interpolate_points(points):
    """Recebe uma lista de pontos (x,y) ou None e retorna uma lista com os
    valores faltantes preenchidos por interpolação linear baseada no índice."""
    n = len(points)
    interp = points.copy()
    for i in range(n):
        if interp[i] is None:
            j = i - 1
            while j >= 0 and interp[j] is None:
                j -= 1
            k = i + 1
            while k < n and interp[k] is None:
                k += 1
            if j >= 0 and k < n:
                t = (i - j) / (k - j)
                x_val = interp[j][0] + t * (interp[k][0] - interp[j][0])
                y_val = interp[j][1] + t * (interp[k][1] - interp[j][1])
                interp[i] = (x_val, y_val)
            elif j >= 0:
                interp[i] = interp[j]
            elif k < n:
                interp[i] = interp[k]
    return interp

# =============================================================================
# Função: Geração dos Parâmetros do Suporte (posição e rotação)
# =============================================================================
def generate_support_parameters():
    angle_deg = random.uniform(-45, 45)  # Ângulo entre -45° e 45°
    theta     = math.radians(angle_deg)
    half_w    = support_width  / 2.0
    half_h    = support_height / 2.0
    dx = abs(half_w * math.cos(theta)) + abs(half_h * math.sin(theta))
    dy = abs(half_w * math.sin(theta)) + abs(half_h * math.cos(theta))
    cx = random.uniform(dx, table_width - dx)
    cy = random.uniform(dy, table_height - dy)
    return cx, cy, theta, angle_deg, half_w, half_h

# =============================================================================
# Função: Desenho do Suporte Real e dos Tubetes (Painel Esquerdo)
# =============================================================================
def draw_real_support(ax, cx, cy, theta, angle_deg, half_w, half_h):
    ax.clear()
    # Desenha a bancada
    table_rect = patches.Rectangle((0, 0), table_width, table_height,
                                   linewidth=1, edgecolor='black', facecolor='whitesmoke')
    ax.add_patch(table_rect)
    
    # Desenha o suporte (calculando o canto inferior esquerdo para aplicar a rotação)
    x0 = cx - half_w * math.cos(theta) + half_h * math.sin(theta)
    y0 = cy - half_w * math.sin(theta) - half_h * math.cos(theta)
    support_rect = patches.Rectangle((x0, y0), support_width, support_height,
                                     angle=angle_deg, linewidth=2,
                                     edgecolor='navy', facecolor='lightblue', alpha=0.5)
    ax.add_patch(support_rect)
    
    # Desenha os tubetes reais (grid de 5x6)
    real_tubes = []
    for i in range(n_rows):
        for j in range(n_cols):
            local_x = -half_w + (j + 0.5) * (support_width / n_cols)
            local_y = -half_h + (i + 0.5) * (support_height / n_rows)
            global_x = cx + local_x * math.cos(theta) - local_y * math.sin(theta)
            global_y = cy + local_x * math.sin(theta) + local_y * math.cos(theta)
            real_tubes.append((global_x, global_y))
            cell_size = min(support_width / n_cols, support_height / n_rows)
            circle = patches.Circle((global_x, global_y), radius=cell_size/4,
                                    edgecolor='black', facecolor='white', linewidth=1)
            ax.add_patch(circle)
    return real_tubes

# =============================================================================
# Função: Simulação das Medições dos Sensores para o Suporte
# =============================================================================
def simulate_sensor_measurement(ax, cx, cy, theta, half_w, half_h):
    # Medição das bordas superior e inferior do suporte (com ruído)
    top_points = []    # Borda superior (local y = +half_h)
    bottom_points = [] # Borda inferior (local y = -half_h)
    
    for k in range(N_meas):
        local_x = -half_w + k * (support_width / (N_meas - 1))
        # Borda superior
        ideal_top_x = cx + local_x * math.cos(theta) - half_h * math.sin(theta)
        ideal_top_y = cy + local_x * math.sin(theta) + half_h * math.cos(theta)
        meas_top_x = ideal_top_x + random.gauss(0, error_std)
        meas_top_y = ideal_top_y + random.gauss(0, error_std)
        top_points.append((meas_top_x, meas_top_y))
        
        # Borda inferior
        ideal_bot_x = cx + local_x * math.cos(theta) - (-half_h) * math.sin(theta)
        ideal_bot_y = cy + local_x * math.sin(theta) + (-half_h) * math.cos(theta)
        meas_bot_x = ideal_bot_x + random.gauss(0, error_std)
        meas_bot_y = ideal_bot_y + random.gauss(0, error_std)
        bottom_points.append((meas_bot_x, meas_bot_y))
    
    # (Neste caso, sem occlusion – usamos todos os pontos para o suporte)
    # Plota as medições na tela
    top_x = [pt[0] for pt in top_points]
    top_y = [pt[1] for pt in top_points]
    bot_x = [pt[0] for pt in bottom_points]
    bot_y = [pt[1] for pt in bottom_points]
    
    ax.plot(top_x, top_y, 'o-', color='darkgreen', markersize=4, label='Borda Superior')
    ax.plot(bot_x, bot_y, 's-', color='darkred', markersize=4, label='Borda Inferior')
    
    return top_points, bottom_points

# =============================================================================
# Função: Simulação das Medições dos Sensores para o Becker
# =============================================================================
def simulate_beaker_measurement(ax, beaker_center, beaker_radius):
    measured_points = []
    angles = [2 * math.pi * i / N_meas for i in range(N_meas)]
    for angle in angles:
        # Ponto ideal na circunferência
        ideal_x = beaker_center[0] + beaker_radius * math.cos(angle)
        ideal_y = beaker_center[1] + beaker_radius * math.sin(angle)
        # Adiciona ruído
        meas_x = ideal_x + random.gauss(0, error_std)
        meas_y = ideal_y + random.gauss(0, error_std)
        measured_points.append((meas_x, meas_y))
    # Estima o centro como a média dos pontos medidos
    est_center_x = sum(pt[0] for pt in measured_points) / len(measured_points)
    est_center_y = sum(pt[1] for pt in measured_points) / len(measured_points)
    est_center = (est_center_x, est_center_y)
    return measured_points, est_center

# =============================================================================
# Função: Cálculo das Posições Estimadas dos Tubetes a partir das Medições do Suporte
# =============================================================================
def calculate_estimated_tubes(top_points, bottom_points):
    # Média dos pontos de cada borda
    mean_top_x = sum(x for x, y in top_points) / len(top_points)
    mean_top_y = sum(y for x, y in top_points) / len(top_points)
    mean_bot_x = sum(x for x, y in bottom_points) / len(bottom_points)
    mean_bot_y = sum(y for x, y in bottom_points) / len(bottom_points)
    
    center_est = ((mean_top_x + mean_bot_x) / 2, (mean_top_y + mean_bot_y) / 2)
    theta_border = math.atan2(mean_top_y - mean_bot_y, mean_top_x - mean_bot_x)
    theta_est = theta_border + math.pi/2  # Corrige para a orientação real do suporte
    
    estimated_tubes = []
    half_w_est = support_width / 2.0
    half_h_est = support_height / 2.0
    for i in range(n_rows):
        for j in range(n_cols):
            local_x = -half_w_est + (j + 0.5) * (support_width / n_cols)
            local_y = -half_h_est + (i + 0.5) * (support_height / n_rows)
            global_x = center_est[0] + local_x * math.cos(theta_est) - local_y * math.sin(theta_est)
            global_y = center_est[1] + local_x * math.sin(theta_est) + local_y * math.cos(theta_est)
            estimated_tubes.append((global_x, global_y))
    return estimated_tubes, center_est, theta_est

# =============================================================================
# Função: Atualiza a Simulação e Visualizações (acionada pelo botão)
# =============================================================================
def update_simulation(event=None):
    # Limpa ambos os eixos para remover os elementos da simulação anterior
    ax1.cla()
    ax2.cla()
    
    # --- Suporte e Tubetes ---
    cx, cy, theta, angle_deg, half_w, half_h = generate_support_parameters()
    real_tubes = draw_real_support(ax1, cx, cy, theta, angle_deg, half_w, half_h)
    top_points, bottom_points = simulate_sensor_measurement(ax2, cx, cy, theta, half_w, half_h)
    estimated_tubes, center_est, theta_est = calculate_estimated_tubes(top_points, bottom_points)
    
    # Desenha os tubetes estimados (círculos com contorno vermelho) no painel direito
    cell_size = min(support_width / n_cols, support_height / n_rows)
    for (ex, ey) in estimated_tubes:
        circle = patches.Circle((ex, ey), radius=cell_size/4,
                                edgecolor='red', facecolor='none', linewidth=1.5)
        ax2.add_patch(circle)
    
    # Calcula o erro do centro do suporte
    center_error = math.hypot(cx - center_est[0], cy - center_est[1])
    
    # --- Becker ---
    # Gera posição aleatória para o becker, garantindo que fique dentro da bancada
    beaker_cx = random.uniform(beaker_radius, table_width - beaker_radius)
    beaker_cy = random.uniform(beaker_radius, table_height - beaker_radius)
    beaker_center = (beaker_cx, beaker_cy)
    
    # No painel esquerdo, desenha o becker real
    beaker_circle = patches.Circle(beaker_center, radius=beaker_radius,
                                   edgecolor='gray', facecolor='lightgray',
                                   linestyle='--', linewidth=2, alpha=0.8)
    ax1.add_patch(beaker_circle)
    
    # No painel direito, simula as medições do becker
    measured_beaker, est_beaker_center = simulate_beaker_measurement(ax2, beaker_center, beaker_radius)
    # Plota os pontos medidos para o becker (em azul)
    for pt in measured_beaker:
        ax2.plot(pt[0], pt[1], 'o', color='blue', markersize=4)
    # Plota o centro estimado do becker (como um 'x' vermelho)
    ax2.plot(est_beaker_center[0], est_beaker_center[1], 'x', color='red', markersize=10, mew=2)
    
    # Calcula o erro para o becker
    beaker_error = math.hypot(beaker_center[0] - est_beaker_center[0],
                              beaker_center[1] - est_beaker_center[1])
    
    # Atualiza os limites, rótulos e grade para ambos os eixos (mesma escala)
    for ax in [ax1, ax2]:
        ax.set_xlim(common_xlim)
        ax.set_ylim(common_ylim)
        ax.set_xlabel("X (mm)")
        ax.set_ylabel("Y (mm)")
        ax.grid(True, linestyle='--', alpha=0.6)
    
    # Exibe informações no painel direito
    info_text = (f"Suporte:\n  Erro do Centro: {center_error:.2f} mm\n"
                 f"  Centro Real: ({cx:.1f}, {cy:.1f})\n"
                 f"  Centro Est.: ({center_est[0]:.1f}, {center_est[1]:.1f})\n"
                 f"  Ângulo Est.: {math.degrees(theta_est):.1f}°\n\n"
                 f"Becker:\n  Erro do Centro: {beaker_error:.2f} mm\n"
                 f"  Centro Real: ({beaker_center[0]:.1f}, {beaker_center[1]:.1f})\n"
                 f"  Centro Est.: ({est_beaker_center[0]:.1f}, {est_beaker_center[1]:.1f})")
    ax2.text(0.98, 0.98, info_text, transform=ax2.transAxes, fontsize=10,
             verticalalignment='top', horizontalalignment='right',
             bbox=dict(facecolor='white', edgecolor='black', boxstyle='round,pad=0.5'))
    
    fig.suptitle("Projeto Mecatrônico", fontsize=16)
    plt.draw()

    
    # Exibe informações no painel direito
    info_text = (f"Suporte:\n  Erro do Centro: {center_error:.2f} mm\n"
                 f"  Centro Real: ({cx:.1f}, {cy:.1f})\n"
                 f"  Centro Est.: ({center_est[0]:.1f}, {center_est[1]:.1f})\n"
                 f"  Ângulo Est.: {math.degrees(theta_est):.1f}°\n\n"
                 f"Becker:\n  Erro do Centro: {beaker_error:.2f} mm\n"
                 f"  Centro Real: ({beaker_center[0]:.1f}, {beaker_center[1]:.1f})\n"
                 f"  Centro Est.: ({est_beaker_center[0]:.1f}, {est_beaker_center[1]:.1f})")
    ax2.text(0.98, 0.98, info_text, transform=ax2.transAxes, fontsize=10,
             verticalalignment='top', horizontalalignment='right',
             bbox=dict(facecolor='white', edgecolor='black', boxstyle='round,pad=0.5'))
    
    fig.suptitle("Projeto Mecatrônico", fontsize=16)
    plt.draw()

# =============================================================================
# Configuração da Janela de Visualização (dois painéis com mesma escala)
# =============================================================================
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 7))
plt.subplots_adjust(bottom=0.25, wspace=0.3)

# Botão para atualizar a simulação
ax_button = plt.axes([0.45, 0.1, 0.1, 0.075])
button = Button(ax_button, 'Atualizar', color='lightgray', hovercolor='silver')
button.on_clicked(update_simulation)

# Inicializa a simulação
update_simulation()
plt.show()
