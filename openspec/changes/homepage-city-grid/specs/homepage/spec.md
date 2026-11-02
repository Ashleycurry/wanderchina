## MODIFIED Requirements

### Requirement: 城市入口与切换

系统 SHALL 在 `city-grid` 渲染恰好 8 个城市项（`href` 形如 `/city/<slug>`），以 `wc_city` cookie 维护当前城市，默认 `SHA`；切换城市后数据区块全部替换且 URL 不含查询参数。

#### Scenario: 首次访问默认城市

- **WHEN** 用户首次打开首页且无 `wc_city` cookie
- **THEN** 返回默认城市 `SHA` 的内容
- **AND** 响应写入 `wc_city` cookie（`Path=/`、`Max-Age` ≥ 30 天），后续请求按该 cookie 取数

#### Scenario: 切换城市联动

- **WHEN** 用户切换到 `BJA`
- **THEN** 三个数据区块全部替换为北京数据，URL 不含脏参数
- **AND** 空区块显示兜底文案而非空白网格

#### Scenario: cookie 非法回退

- **WHEN** `wc_city` 取值为非法城市码，或 cookie 写入被浏览器拒绝
- **THEN** 非法值按默认城市 `SHA` 取数；写入失败时保持当前服务端城市
- **AND** 页面正常渲染，不报错、不白屏

#### Scenario: 城市网格条目与链接

- **WHEN** 查看 `city-grid` 的 DOM
- **THEN** 存在恰好 8 个城市项，每项含可见图标与城市名
- **AND** `href` 分别为 `/city/shanghai`、`/city/beijing`、`/city/xian`、`/city/chengdu`、`/city/hangzhou`、`/city/guilin`、`/city/lijiang`、`/city/suzhou`

#### Scenario: 切换为局部刷新

- **WHEN** 用户左键点击非当前城市项
- **THEN** 仅触发 `router.refresh()` 局部刷新，页面不整页重载
- **AND** 地址栏 URL 保持 `/`，不新增 `cityCode` / `city` 等查询参数

#### Scenario: 键盘可达与当前城市标识

- **WHEN** 用户仅用键盘 Tab 导航
- **THEN** 8 个城市项依次可达，`focus-visible` 环可见
- **AND** 当前城市项带 `aria-current="true"`
