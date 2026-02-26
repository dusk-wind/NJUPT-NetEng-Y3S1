import torch
import torch.nn as nn
import torch.optim as optim

# Data Synthesis

num_samples = 500
seq_len = 20
feature_dim = 10
num_classes = 3

X = torch.randn(num_samples, seq_len, feature_dim)
y = torch.randint(0, num_classes, (num_samples,))

# Split
train_size = int(0.8 * num_samples)
X_train, X_test = X[:train_size], X[train_size:]
y_train, y_test = y[:train_size], y[train_size:]

# Model
class TimeSeriesTransformer(nn.Module):
    def __init__(self, feature_dim, num_classes, num_heads=2, num_layers=2, hidden_dim=64):
        super(TimeSeriesTransformer, self).__init__()
        
        # Input embedding (linear projection)
        self.input_proj = nn.Linear(feature_dim, hidden_dim)
        
        # Positional encoding
        self.pos_embedding = nn.Parameter(torch.randn(1, seq_len, hidden_dim))
        
        # Transformer encoder
        encoder_layer = nn.TransformerEncoderLayer(
            d_model=hidden_dim, nhead=num_heads, batch_first=True
        )
        self.transformer = nn.TransformerEncoder(encoder_layer, num_layers=num_layers)
        
        # Classification head
        self.fc = nn.Linear(hidden_dim, num_classes)

    def forward(self, x):
        # x: [batch, seq_len, feature_dim]
        x = self.input_proj(x) + self.pos_embedding[:, :x.size(1), :]
        x = self.transformer(x)  # [batch, seq_len, hidden_dim]
        
        # Use mean pooling over sequence
        x = x.mean(dim=1)
        return self.fc(x)

# Training
model = TimeSeriesTransformer(feature_dim, num_classes)
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=1e-3)

epochs = 10
for epoch in range(epochs):
    model.train()
    optimizer.zero_grad()
    outputs = model(X_train)
    loss = criterion(outputs, y_train)
    loss.backward()
    optimizer.step()
    
# Evaluating
    model.eval()
    with torch.no_grad():
        preds = model(X_test).argmax(dim=1)
        acc = (preds == y_test).float().mean()
    print(f"Epoch {epoch+1}, Loss: {loss.item():.4f}, Test Acc: {acc.item():.4f}")