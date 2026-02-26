import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import torch
import torch.nn as nn
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_absolute_error, mean_squared_error

# 1. 现代化模型定义：支持切换 LSTM/GRU
class RNNModel(nn.Module):
    def __init__(self, model_type, num_classes, input_size, hidden_size, num_layers):
        super(RNNModel, self).__init__()
        self.model_type = model_type
        self.num_layers = num_layers
        self.hidden_size = hidden_size
        
        # 根据参数选择 LSTM 或 GRU
        if model_type == 'LSTM':
            self.rnn = nn.LSTM(input_size=input_size, hidden_size=hidden_size,
                               num_layers=num_layers, batch_first=True)
        else:
            self.rnn = nn.GRU(input_size=input_size, hidden_size=hidden_size,
                              num_layers=num_layers, batch_first=True)
        
        self.fc = nn.Linear(hidden_size, num_classes)

    def forward(self, x):
        # 自动识别设备 (CPU/GPU)
        device = x.device
        h_0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size).to(device)
        
        if self.model_type == 'LSTM':
            c_0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size).to(device)
            ula, (h_out, _) = self.rnn(x, (h_0, c_0))
        else:
            ula, h_out = self.rnn(x, h_0)
        
        # 取最后一个时间步的输出
        h_out = h_out[-1].view(-1, self.hidden_size)
        out = self.fc(h_out)
        return out

def sliding_windows(data, seq_length):
    x, y = [], []
    for i in range(len(data)-seq_length-1):
        x.append(data[i:(i+seq_length)])
        y.append(data[i+seq_length])
    return np.array(x), np.array(y)

# 2. 环境设置
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using device: {device}")

# 3. 数据加载与预处理
training_set = pd.read_csv('airline-passengers.csv')
training_data_raw = training_set.iloc[:, 1:2].values

sc = MinMaxScaler()
training_data = sc.fit_transform(training_data_raw)

seq_length = 4
x, y = sliding_windows(training_data, seq_length)

train_size = int(len(y) * 0.67)
# 转换为张量并移动到指定设备
dataX = torch.Tensor(x).to(device)
dataY = torch.Tensor(y).to(device)
trainX = dataX[:train_size]
trainY = dataY[:train_size]
testX = dataX[train_size:]
testY = dataY[train_size:]

# 4. 超参数设置（实验二提高要求：调节参数）
model_type = 'LSTM'  # 可改为 'GRU'
num_epochs = 2000
learning_rate = 0.01
input_size = 1
hidden_size = 32     # 将基线的 2 增加到 32，观察拟合能力提升
num_layers = 1
num_classes = 1

model = RNNModel(model_type, num_classes, input_size, hidden_size, num_layers).to(device)

criterion = nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)

# 5. 训练循环
loss_history = []
for epoch in range(num_epochs):
    model.train()
    outputs = model(trainX)
    optimizer.zero_grad()
    loss = criterion(outputs, trainY)
    loss.backward()
    optimizer.step()
    
    loss_history.append(loss.item())
    if epoch % 200 == 0:
        print(f"Epoch: {epoch}, Loss: {loss.item():.5f}")

# 6. 评估与多指标计算（实验二提高要求：不同评价标准）
model.eval()
with torch.no_grad():
    train_predict = model(dataX).cpu().numpy()
    dataY_true = dataY.cpu().numpy()

# 反归一化
train_predict_rescaled = sc.inverse_transform(train_predict)
dataY_true_rescaled = sc.inverse_transform(dataY_true)

# 计算测试集指标
test_predict = train_predict_rescaled[train_size:]
test_true = dataY_true_rescaled[train_size:]

mae = mean_absolute_error(test_true, test_predict)
rmse = np.sqrt(mean_squared_error(test_true, test_predict))

print(f"\n--- Evaluation Metrics (Test Set) ---")
print(f"MAE: {mae:.2f}")
print(f"RMSE: {rmse:.2f}")

# 7. 可视化
plt.figure(figsize=(10, 6))
plt.axvline(x=train_size, c='r', linestyle='--', label='Train/Test Split')
plt.plot(dataY_true_rescaled, label='Actual Data', color='blue', alpha=0.6)
plt.plot(train_predict_rescaled, label='Predicted Data', color='orange', linestyle='--')
plt.title(f'Time-Series Prediction ({model_type}, hidden={hidden_size})')
plt.xlabel('Month')
plt.ylabel('Passengers')
plt.legend()
plt.show()