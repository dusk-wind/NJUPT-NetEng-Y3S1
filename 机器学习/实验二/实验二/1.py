import matplotlib.pyplot as plt
import numpy as np

# 1. 整理数据
# Epoch 1-2 的数据 (来自你上一次发的结果)
loss_epoch_1_2 = [2.219, 1.960, 1.770, 1.644, 1.564, 1.541, 1.513, 1.438, 1.450, 1.416, 1.412, 1.393]
# Epoch 3-10 的数据 (来自你之前发的结果)
loss_epoch_3_10 = [1.368, 1.345, 1.348, 1.336, 1.344, 1.331, 1.301, 1.287, 1.285, 1.287, 1.295, 1.277,
                   1.237, 1.246, 1.236, 1.247, 1.261, 1.236, 1.225, 1.189, 1.220, 1.215, 1.197, 1.220,
                   1.166, 1.181, 1.174, 1.200, 1.184, 1.189, 1.116, 1.172, 1.162, 1.163, 1.174, 1.168,
                   1.121, 1.156, 1.126, 1.147, 1.135, 1.157, 1.084, 1.115, 1.112, 1.122, 1.140, 1.145]

full_loss = loss_epoch_1_2 + loss_epoch_3_10
iterations = [i * 2000 for i in range(1, len(full_loss) + 1)]

# 2. 开始画图
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))

# 图 1: Loss 曲线
ax1.plot(iterations, full_loss, label='Training Loss', color='#1f77b4', linewidth=2)
ax1.axvline(x=2*12000, color='r', linestyle='--', label='End of Epoch 2') # 标注基线位置
ax1.set_title('CNN Training Loss over 10 Epochs', fontsize=14)
ax1.set_xlabel('Iterations', fontsize=12)
ax1.set_ylabel('Cross Entropy Loss', fontsize=12)
ax1.grid(True, alpha=0.3)
ax1.legend()

# 图 2: Accuracy 对比柱状图
epochs = ['Epoch 2 (Baseline)', 'Epoch 10 (Tuned)']
accuracies = [51, 56]
bars = ax2.bar(epochs, accuracies, color=['#ff7f0e', '#2ca02c'], width=0.5)
ax2.set_title('Test Accuracy Comparison', fontsize=14)
ax2.set_ylabel('Accuracy (%)', fontsize=12)
ax2.set_ylim(0, 70)

# 在柱状图上显示具体数值
for bar in bars:
    height = bar.get_height()
    ax2.text(bar.get_x() + bar.get_width()/2., height + 1, f'{height}%', ha='center', va='bottom', fontsize=12)

plt.tight_layout()
plt.savefig('task1_comparison.png')
plt.show()