### sonyflake
>雪花算法 [go - Sonyflake](https://github.com/sony/sonyflake) 的仓颉实现

    39 bits for time in units of 10 msec
     8 bits for a sequence number
    16 bits for a machine id

Sonyflake 具有以下优点和缺点：
- 寿命（174年）比雪花（69年）长
- 它可以在比 Snowflake (2^10) 更多的分布式机器 (2^16) 上工作
- 单机/线程每10毫秒最多生成2^8个ID（比Snowflake慢）

### 安装
1. beta channel版本在`cjpm.toml`里添加
```toml
[dependencies]
  sonyflake = { git = "https://github.com/ystyle/sonyflake-cj", branch = "0.53"}
```
2. dev channel版本在`cjpm.toml`里添加
```toml
[dependencies]
  sonyflake = { git = "https://github.com/ystyle/sonyflake-cj", branch = "master"}
```

### sample
```go
import sonyflake.*

func main() {
    let st  = Setting(1)
    let sf = Sonyflake(st)
    let id = sf.NextID()
    println("id: ${id}")
}
```