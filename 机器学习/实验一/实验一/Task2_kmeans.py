import matplotlib.pyplot as plt

# Though the following import is not directly being used, it is required
# for 3D projection to work with matplotlib < 3.2
import mpl_toolkits.mplot3d  
import numpy as np

from sklearn import datasets
from sklearn.cluster import KMeans

np.random.seed(5)

iris = datasets.load_iris()
X = iris.data
y = iris.target

estimators = [
    ("k_means_iris_8", KMeans(n_clusters=8)),
    ("k_means_iris_3", KMeans(n_clusters=3)),
    ("k_means_iris_bad_init", KMeans(n_clusters=3, n_init=1, init="random")),
]

fig = plt.figure(figsize=(10, 8))
titles = ["8 clusters", "3 clusters", "3 clusters, bad initialization"]
for idx, ((name, est), title) in enumerate(zip(estimators, titles)):
    ax = fig.add_subplot(2, 2, idx + 1, projection="3d", elev=48, azim=134)
    est.fit(X)
    labels = est.labels_
    print(labels)

    ax.scatter(X[:, 3], X[:, 0], X[:, 2], c=labels.astype(float), edgecolor="k")

    ax.xaxis.set_ticklabels([])
    ax.yaxis.set_ticklabels([])
    ax.zaxis.set_ticklabels([])
    ax.set_xlabel("Petal width")
    ax.set_ylabel("Sepal length")
    ax.set_zlabel("Petal length")
    ax.set_title(title)

# Plot the ground truth
ax = fig.add_subplot(2, 2, 4, projection="3d", elev=48, azim=134)

for name, label in [("Setosa", 0), ("Versicolour", 1), ("Virginica", 2)]:
    ax.text3D(
        X[y == label, 3].mean(),
        X[y == label, 0].mean(),
        X[y == label, 2].mean() + 2,
        name,
        horizontalalignment="center",
        bbox=dict(alpha=0.2, edgecolor="w", facecolor="w"),
    )

ax.scatter(X[:, 3], X[:, 0], X[:, 2], c=y, edgecolor="k")

ax.xaxis.set_ticklabels([])
ax.yaxis.set_ticklabels([])
ax.zaxis.set_ticklabels([])
ax.set_xlabel("Petal width")
ax.set_ylabel("Sepal length")
ax.set_zlabel("Petal length")
ax.set_title("Ground Truth")

plt.subplots_adjust(wspace=0.25, hspace=0.25)
plt.show()

#评价指标
# 导入计算指标所需的函数
from sklearn.metrics import adjusted_rand_score, silhouette_score

print("\n\n--- 聚类性能量化评估指标 ---")

# estimators 列表中的模型已经在上面的循环中被训练 (fit) 过了
# 我们现在可以直接使用它们的聚类结果 (est.labels_)

for name, est in estimators:
    # 从已经训练好的模型中获取预测的簇标签
    labels_pred = est.labels_
    
    # 1. 计算调整兰德指数 (Adjusted Rand Index, ARI)
    #    这个指标需要与真实标签 y 进行比较
    ari = adjusted_rand_score(y, labels_pred)
    
    # 2. 计算轮廓系数 (Silhouette Score)
    #    这个指标不需要真实标签，只评估聚类本身的质量
    silhouette = silhouette_score(X, labels_pred)
    
    print(f"\n配置: {name}")
    print(f"  调整兰德指数 (ARI): {ari:.4f}")
    print(f"  轮廓系数 (Silhouette Score): {silhouette:.4f}")