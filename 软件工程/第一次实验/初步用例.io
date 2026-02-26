<mxfile>
  <diagram id="3" name="自行车违停智能识别系统-带角色小人用例图">
    <mxGraphModel dx="1200" dy="800" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1169" pageHeight="827" math="0" shadow="0">
      <root>
        <mxCell id="0"/>
        <mxCell id="1" parent="0"/>
        
        <!-- 角色1：系统管理员（带小人图标） -->
        <!-- 小人图标：用基础图形组合模拟，椭圆+矩形+线条 -->
        <mxCell id="2" value="" style="ellipse;fillColor:#FFD700;strokeColor:#FFA500;strokeWidth:1;" vertex="1" parent="1">
          <mxGeometry x="130" y="180" width="60" height="60" as="geometry"/>
        </mxCell>
        <mxCell id="3" value="" style="rectangle;fillColor:#4CAF50;strokeColor:#2E7D32;strokeWidth:1;" vertex="1" parent="1">
          <mxGeometry x="130" y="240" width="60" height="80" as="geometry"/>
        </mxCell>
        <mxCell id="4" value="" style="line;strokeColor:#2E7D32;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="140" y="320" as="source"/>
            <mxPoint x="120" y="380" as="target"/>
          </mxGeometry>
        </mxCell>
        <mxCell id="5" value="" style="line;strokeColor:#2E7D32;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="170" y="320" as="source"/>
            <mxPoint x="190" y="380" as="target"/>
          </mxGeometry>
        </mxCell>
        <!-- 管理员角色标签 -->
        <mxCell id="6" value="&lt;b&gt;系统管理员&lt;/b&gt;" style="label;fontSize:14;align:center;verticalAlign:middle;fillColor:transparent;strokeColor:transparent;" vertex="1" parent="1">
          <mxGeometry x="100" y="400" width="120" height="30" as="geometry"/>
        </mxCell>
        
        <!-- 角色2：系统运维人员（带小人图标） -->
        <mxCell id="7" value="" style="ellipse;fillColor:#87CEEB;strokeColor:#4169E1;strokeWidth:1;" vertex="1" parent="1">
          <mxGeometry x="130" y="480" width="60" height="60" as="geometry"/>
        </mxCell>
        <mxCell id="8" value="" style="rectangle;fillColor:#2196F3;strokeColor:#1565C0;strokeWidth:1;" vertex="1" parent="1">
          <mxGeometry x="130" y="540" width="60" height="80" as="geometry"/>
        </mxCell>
        <mxCell id="9" value="" style="line;strokeColor:#1565C0;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="140" y="620" as="source"/>
            <mxPoint x="120" y="680" as="target"/>
          </mxGeometry>
        </mxCell>
        <mxCell id="10" value="" style="line;strokeColor:#1565C0;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="170" y="620" as="source"/>
            <mxPoint x="190" y="680" as="target"/>
          </mxGeometry>
        </mxCell>
        <!-- 运维人员角色标签 -->
        <mxCell id="11" value="&lt;b&gt;系统运维人员&lt;/b&gt;" style="label;fontSize:14;align:center;verticalAlign:middle;fillColor:transparent;strokeColor:transparent;" vertex="1" parent="1">
          <mxGeometry x="100" y="700" width="120" height="30" as="geometry"/>
        </mxCell>
        
        <!-- 系统边界 -->
        <mxCell id="12" value="&lt;b&gt;自行车违停智能识别系统&lt;/b&gt;" style="rectangle;strokeColor:#FF8F00;strokeWidth:3;fillColor:transparent;fillColor2:transparent;fontSize:16;align:center;verticalAlign:middle;" vertex="1" parent="1">
          <mxGeometry x="250" y="100" width="700" height="650" as="geometry"/>
        </mxCell>
        
        <!-- 用例1：违停记录管理（文档3.2.1页面功能） -->
        <mxCell id="13" value="&lt;b&gt;违停记录管理&lt;/b&gt;&lt;BR&gt;- 查看历史记录&lt;BR&gt;- 多条件查询&lt;BR&gt;- Excel导出" style="roundedRectangle;fillColor:#E0F7FA;strokeColor:#006064;strokeWidth:2;fontSize:12;align:center;verticalAlign:middle;padding:10;" vertex="1" parent="1">
          <mxGeometry x="300" y="150" width="180" height="100" as="geometry"/>
        </mxCell>
        
        <!-- 用例2：实时监控查看（文档1.2前端感知层） -->
        <mxCell id="14" value="&lt;b&gt;实时监控查看&lt;/b&gt;&lt;BR&gt;- 摄像头画面预览&lt;BR&gt;- 违规实时标注&lt;BR&gt;- 多摄像头切换" style="roundedRectangle;fillColor:#E0F7FA;strokeColor:#006064;strokeWidth:2;fontSize:12;align:center;verticalAlign:middle;padding:10;" vertex="1" parent="1">
          <mxGeometry x="520" y="150" width="180" height="100" as="geometry"/>
        </mxCell>
        
        <!-- 用例3：数据可视化分析（文档3.2.1页面功能） -->
        <mxCell id="15" value="&lt;b&gt;数据可视化分析&lt;/b&gt;&lt;BR&gt;- 违停趋势图表&lt;BR&gt;- 高发区域统计&lt;BR&gt;- 置信度分布" style="roundedRectangle;fillColor:#E0F7FA;strokeColor:#006064;strokeWidth:2;fontSize:12;align:center;verticalAlign:middle;padding:10;" vertex="1" parent="1">
          <mxGeometry x="740" y="150" width="180" height="100" as="geometry"/>
        </mxCell>
        
        <!-- 用例4：摄像头设备管理（文档1.2.2硬件部署） -->
        <mxCell id="16" value="&lt;b&gt;摄像头设备管理&lt;/b&gt;&lt;BR&gt;- 设备状态监控&lt;BR&gt;- 连接参数配置&lt;BR&gt;- 设备启停控制" style="roundedRectangle;fillColor:#E0F7FA;strokeColor:#006064;strokeWidth:2;fontSize:12;align:center;verticalAlign:middle;padding:10;" vertex="1" parent="1">
          <mxGeometry x="300" y="320" width="180" height="100" as="geometry"/>
        </mxCell>
        
        <!-- 用例5：违规预警管理（文档0.1智能预警机制） -->
        <mxCell id="17" value="&lt;b&gt;违规预警管理&lt;/b&gt;&lt;BR&gt;- 预警信息查看&lt;BR&gt;- 预警阈值设置&lt;BR&gt;- 预警状态标记" style="roundedRectangle;fillColor:#E0F7FA;strokeColor:#006064;strokeWidth:2;fontSize:12;align:center;verticalAlign:middle;padding:10;" vertex="1" parent="1">
          <mxGeometry x="520" y="320" width="180" height="100" as="geometry"/>
        </mxCell>
        
        <!-- 用例6：模型运维管理（文档1.2.3模型部署） -->
        <mxCell id="18" value="&lt;b&gt;模型运维管理&lt;/b&gt;&lt;BR&gt;- 模型版本切换&lt;BR&gt;- 推理性能监控&lt;BR&gt;- 模型量化更新" style="roundedRectangle;fillColor:#FFF3E0;strokeColor:#E65100;strokeWidth:2;fontSize:12;align:center;verticalAlign:middle;padding:10;" vertex="1" parent="1">
          <mxGeometry x="740" y="320" width="180" height="100" as="geometry"/>
        </mxCell>
        
        <!-- 用例7：系统权限管理（文档1.3.2后端架构） -->
        <mxCell id="19" value="&lt;b&gt;系统权限管理&lt;/b&gt;&lt;BR&gt;- 用户账号管理&lt;BR&gt;- 角色权限分配&lt;BR&gt;- 操作日志查看" style="roundedRectangle;fillColor:#E8F5E9;strokeColor:#2E7D32;strokeWidth:2;fontSize:12;align:center;verticalAlign:middle;padding:10;" vertex="1" parent="1">
          <mxGeometry x="300" y="490" width="180" height="100" as="geometry"/>
        </mxCell>
        
        <!-- 用例8：边缘设备监控（文档1.2.1硬件规格） -->
        <mxCell id="20" value="&lt;b&gt;边缘设备监控&lt;/b&gt;&lt;BR&gt;- RDK X5状态查看&lt;BR&gt;- CPU/BPU利用率监控&lt;BR&gt;- 内存占用统计" style="roundedRectangle;fillColor:#FFF3E0;strokeColor:#E65100;strokeWidth:2;fontSize:12;align:center;verticalAlign:middle;padding:10;" vertex="1" parent="1">
          <mxGeometry x="520" y="490" width="180" height="100" as="geometry"/>
        </mxCell>
        
        <!-- 用例9：在线模型调用（文档3.2.1页面功能） -->
        <mxCell id="21" value="&lt;b&gt;在线模型调用&lt;/b&gt;&lt;BR&gt;- 上传图像检测&lt;BR&gt;- 检测结果返回&lt;BR&gt;- 标注图片下载" style="roundedRectangle;fillColor:#E0F7FA;strokeColor:#006064;strokeWidth:2;fontSize:12;align:center;verticalAlign:middle;padding:10;" vertex="1" parent="1">
          <mxGeometry x="740" y="490" width="180" height="100" as="geometry"/>
        </mxCell>
        
        <!-- 管理员-用例连接 -->
        <mxCell id="22" value="" style="relationship;startArrow:arrow;endArrow:arrow;strokeColor:#2E7D32;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="200" y="250" as="source"/>
            <mxPoint x="300" y="200" as="target"/>
          </mxGeometry>
        </mxCell>
        <mxCell id="23" value="" style="relationship;startArrow:arrow;endArrow:arrow;strokeColor:#2E7D32;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="200" y="250" as="source"/>
            <mxPoint x="520" y="200" as="target"/>
          </mxGeometry>
        </mxCell>
        <mxCell id="24" value="" style="relationship;startArrow:arrow;endArrow:arrow;strokeColor:#2E7D32;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="200" y="250" as="source"/>
            <mxPoint x="740" y="200" as="target"/>
          </mxGeometry>
        </mxCell>
        <mxCell id="25" value="" style="relationship;startArrow:arrow;endArrow:arrow;strokeColor:#2E7D32;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="200" y="250" as="source"/>
            <mxPoint x="300" y="370" as="target"/>
          </mxGeometry>
        </mxCell>
        <mxCell id="26" value="" style="relationship;startArrow:arrow;endArrow:arrow;strokeColor:#2E7D32;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="200" y="250" as="source"/>
            <mxPoint x="520" y="370" as="target"/>
          </mxGeometry>
        </mxCell>
        <mxCell id="27" value="" style="relationship;startArrow:arrow;endArrow:arrow;strokeColor:#2E7D32;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="200" y="250" as="source"/>
            <mxPoint x="300" y="540" as="target"/>
          </mxGeometry>
        </mxCell>
        <mxCell id="28" value="" style="relationship;startArrow:arrow;endArrow:arrow;strokeColor:#2E7D32;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="200" y="250" as="source"/>
            <mxPoint x="740" y="540" as="target"/>
          </mxGeometry>
        </mxCell>
        
        <!-- 运维人员-用例连接 -->
        <mxCell id="29" value="" style="relationship;startArrow:arrow;endArrow:arrow;strokeColor:#1565C0;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="200" y="550" as="source"/>
            <mxPoint x="300" y="370" as="target"/>
          </mxGeometry>
        </mxCell>
        <mxCell id="30" value="" style="relationship;startArrow:arrow;endArrow:arrow;strokeColor:#1565C0;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="200" y="550" as="source"/>
            <mxPoint x="520" y="370" as="target"/>
          </mxGeometry>
        </mxCell>
        <mxCell id="31" value="" style="relationship;startArrow:arrow;endArrow:arrow;strokeColor:#1565C0;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="200" y="550" as="source"/>
            <mxPoint x="740" y="370" as="target"/>
          </mxGeometry>
        </mxCell>
        <mxCell id="32" value="" style="relationship;startArrow:arrow;endArrow:arrow;strokeColor:#1565C0;strokeWidth:2;" edge="1" parent="1">
          <mxGeometry relative="1" as="geometry">
            <mxPoint x="200" y="550" as="source"/>
            <mxPoint x="520" y="540" as="target"/>
          </mxGeometry>
        </mxCell>
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>