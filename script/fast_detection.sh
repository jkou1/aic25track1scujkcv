#!/usr/bin/env bash

# Register a function to be called on exit
function cleanup {
  echo "Cleaning up..."
  pkill -P $$ # Kill all child processes of this script
}

trap cleanup EXIT

set -x

# 定义场景的起始和结束索引
start=61
end=90
start_gpu=1
gpu_nums_per_iter=5 # gpu_nums_per_iter >= 1
cpu_nums_per_item=4 #cpu_nums_per_item >= 1
scene_per_iter=30   #scene_per_iter={1,2,5,10,15,30}


for ((j=0; j < ($end-$start+1) / $scene_per_iter; j++)); do
  # 使用for循环遍历场景
  for ((i = $start + $j * $scene_per_iter; i < $start + $j * $scene_per_iter + $scene_per_iter; i++)); do
      # 计算当前场景所在的GPU编号
      gpu_index=$((($i - $start - $j * $scene_per_iter) * $gpu_nums_per_iter / $scene_per_iter + $start_gpu))

      # 设置CUDA_VISIBLE_DEVICES环境变量以限制使用特定的GPU
      export CUDA_VISIBLE_DEVICES=$[$gpu_index]

      taskset -c $[$cpu_nums_per_item*$[$i-$start]]-$[$cpu_nums_per_item*$[$i-$start]+$cpu_nums_per_item-1] python detection/get_detection.py --scene $i --trt True&
  done
  wait
done

wait