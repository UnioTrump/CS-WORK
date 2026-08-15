clear; clc;

% 完整数据 (1997-2010)
years = (1997:2010)';
data = [791.69; 855.97; 929.09; 1007.57; 1124.75; 1254.97; 1234.11; ...
        1402.88; 1516.47; 1605.02; 1845.50; 2060.00; 2250.33; 2587.35];

% 使用指数增长模型 (修正了指数项符号)
f = fittype('a*exp(b*(t-1997))+c', 'independent', 't', ...
            'coefficients', {'a', 'b', 'c'});

% 执行拟合
[cfun, gof] = fit(years, data, f);

% 显示拟合结果
disp('拟合结果:');
disp(cfun);
fprintf('拟合优度 R² = %.4f\n', gof.rsquare);

% 生成预测年份 (1997-2015)
pred_years = (1997:2015)';
pred_values = cfun(pred_years);

% 分离历史数据和未来预测
history_years = 1997:2010;
future_years = 2011:2015;

% 绘图
figure;
set(gcf, 'Position', [100, 100, 800, 500]);

% 绘制历史数据
plot(history_years, data, 'b-o', 'LineWidth', 2, 'MarkerSize', 8, ...
     'MarkerFaceColor', 'b', 'DisplayName', '实际数据');
hold on;

% 绘制拟合曲线 (1997-2010)
plot(history_years, cfun(history_years), 'g--', 'LineWidth', 2, ...
     'DisplayName', '拟合曲线');

% 绘制预测曲线 (2011-2015)
plot(future_years, pred_values(15:end), 'r-', 'LineWidth', 2, ...
     'DisplayName', '预测值');

% 添加预测起始线
xline(2010, 'k--', 'LineWidth', 1.5, 'DisplayName', '预测起始点');

% 标记预测点
plot(2010, pred_values(14), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', ...
     'HandleVisibility', 'off');
plot(2011, pred_values(15), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r', ...
     'DisplayName', '预测点');

grid on;
xlabel('年份', 'FontSize', 12);
ylabel('旅游人数 (万人)', 'FontSize', 12);
title('指数模型对旅游人数的拟合与预测', 'FontSize', 14);
legend('Location', 'northwest', 'FontSize', 10);
set(gca, 'FontSize', 10);

% 显示2011-2015年预测结果
fprintf('\n2011-2015年预测结果:\n');
fprintf('年份\t预测值\n');
for i = 1:5
    fprintf('%d\t%.2f\n', future_years(i), pred_values(14+i));
end

% 计算拟合误差
fit_values = cfun(history_years);
errors = abs(data - fit_values);
rel_errors = errors ./ data * 100;

% 显示拟合误差
fprintf('\n拟合误差分析:\n');
fprintf('年份\t实际值\t拟合值\t绝对误差\t相对误差(%%)\n');
for i = 1:length(data)
    fprintf('%d\t%.2f\t%.2f\t%.2f\t\t%.2f\n', ...
            history_years(i), data(i), fit_values(i), errors(i), rel_errors(i));
end

% 模型评估指标
mse = mean(errors.^2);
rmse = sqrt(mse);
fprintf('\n模型评估指标:\n');
fprintf('均方误差 (MSE) = %.2f\n', mse);
fprintf('均方根误差 (RMSE) = %.2f\n', rmse);
fprintf('确定系数 (R²) = %.4f\n', gof.rsquare);