# Helm Chart 說明

本 Helm Chart 整合了 [NVIDIA GPU Operator](https://github.com/NVIDIA/gpu-operator) 及 [HAMi](https://github.com/Project-HAMi/HAMi) 兩個套件，並透過 `nodeSelector` 來選擇要部署的節點。所有操作均已寫入 `Makefile`，可透過指令快速執行安裝、升級及移除。

## 目錄

- [Makefile 操作說明](#makefile-操作說明)

---

## Makefile 操作說明

本專案已提供 `Makefile` 提供常用操作指令：

- `make install`：安裝 Helm Chart
- `make upgrade`：升級 Helm Chart
- `make uninstall`：移除 Helm Chart

---

## 參考連結

- [NVIDIA GPU Operator](https://github.com/NVIDIA/gpu-operator)
- [HAMi](https://github.com/Project-HAMi/HAMi)
- [Helm 官方文件](https://helm.sh/docs/)
