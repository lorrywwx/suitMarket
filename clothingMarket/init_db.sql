-- 创建数据库
CREATE DATABASE IF NOT EXISTS clothing_market DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE clothing_market;

-- 创建用户表
CREATE TABLE IF NOT EXISTS user (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(80) NOT NULL UNIQUE,
    email VARCHAR(120) UNIQUE,
    password VARCHAR(128) NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    img VARCHAR(200) DEFAULT '/static/images/default-avatar.png',
    is_admin BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `user`(`id`, `username`, `email`, `password`, `phone`, `address`, `img`, `is_admin`, `status`, `created_at`, `updated_at`) VALUES (1, 'admin', 'admin@example.com', '123456', NULL, NULL, '/static/images/default-avatar.png', 1, 'active', '2025-04-14 00:14:31', '2025-04-14 00:14:31');
INSERT INTO `user`(`id`, `username`, `email`, `password`, `phone`, `address`, `img`, `is_admin`, `status`, `created_at`, `updated_at`) VALUES (2, 'test', 'wwx@qq.com', '123456', 'None', 'None', '/static/uploads/avatars/20250414152650_2.png', 0, 'active', '2025-04-14 00:14:31', '2025-04-14 07:26:52');

-- 创建商品分类表
CREATE TABLE IF NOT EXISTS category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `category`(`id`, `name`, `description`, `created_at`) VALUES (1, '上衣', '包括T恤、衬衫、卫衣等各类上装', '2025-04-14 00:14:31');
INSERT INTO `category`(`id`, `name`, `description`, `created_at`) VALUES (2, '裤装', '包括牛仔裤、休闲裤、运动裤等各类裤装', '2025-04-14 00:14:31');
INSERT INTO `category`(`id`, `name`, `description`, `created_at`) VALUES (3, '鞋类', '包括运动鞋、休闲鞋、皮鞋等各类鞋履', '2025-04-14 00:14:31');
INSERT INTO `category`(`id`, `name`, `description`, `created_at`) VALUES (4, '配饰', '包括帽子、围巾、手套等配饰', '2025-04-14 00:14:31');

-- 创建商品表
CREATE TABLE IF NOT EXISTS product (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    category_id INT NOT NULL,
    image_url VARCHAR(200),
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES category(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (4, '男工服装', '超帅的男装', 999.00, 18, 1, 'https://cbu01.alicdn.com/img/ibank/O1CN01XetExz2DVj3RjEa91_!!2215903558615-0-cib.jpg', 'active', '2025-04-13 09:44:45', '2025-04-14 01:52:26');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (5, '美式重磅250g纯棉短袖T恤男', '2025新款夏季宽松基础百搭纯色打底衫', 78.00, 17, 1, 'https://gw.alicdn.com/imgextra/i1/2894696740/O1CN01rxu7VG1zeyQSVwvME_!!2894696740.jpg', 'active', '2025-04-13 09:51:30', '2025-04-14 01:39:11');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (6, 'polo衫男士', '暴汗速干无汗渍夏季商务凉感翻领运动上衣短袖t恤', 159.00, 18, 1, 'https://gw.alicdn.com/bao/uploaded/i1/1652864050/O1CN010bQIwr1fmx6W6uNAM_!!1652864050.jpg', 'active', '2025-04-13 09:54:44', '2025-04-14 01:39:11');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (7, ' 森马集团纯棉短袖t恤男士', '夏季宽松学生圆领运动上衣薄款半袖衫潮', 39.00, 16, 1, 'https://img.alicdn.com/imgextra/i1/2808740824/O1CN01Gqzhxc1HxROILN96n_!!2808740824.jpg_.webp', 'active', '2025-04-13 09:56:07', '2025-04-14 01:52:56');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (8, '美式复古肌理感提花短袖T恤男', '夏季2025新款潮流高级感休闲上衣男', 98.00, 19, 1, 'https://gw.alicdn.com/bao/uploaded/i2/2894696740/O1CN01h1tRuA1zeyWYIUgxJ_!!2894696740.jpg', 'active', '2025-04-13 09:57:15', '2025-04-14 01:39:11');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (9, 'GXG男装 ', '粗斜纹肌理polo衫绣花休闲翻领短袖上衣 25夏新品', 193.00, 20, 1, 'https://gw.alicdn.com/bao/uploaded/i4/454291526/O1CN01xsAX8U1N8xQzJd95O-454291526.jpg_.webp', 'active', '2025-04-13 10:00:14', '2025-04-13 10:00:14');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (10, '唐狮集团DESSO短袖t恤男生', '夏季2025新款美式重磅纯棉半袖体恤衣服', 45.00, 20, 1, 'https://gw.alicdn.com/bao/uploaded/i1/198849853/O1CN01hDPkRY2MejMksOavI_!!198849853.jpg', 'active', '2025-04-13 10:01:05', '2025-04-13 10:01:05');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (11, 'Hualun春秋高级感衬衫套装男', '休闲运动一整套搭配cleanfit韩版一套', 198.00, 22, 1, 'https://gw.alicdn.com/imgextra/i3/2899240446/O1CN01EScLUn1FAJgNErafN_!!2899240446.jpg', 'active', '2025-04-13 10:03:43', '2025-04-13 10:03:43');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (12, 'NARTALIY扎染条纹短袖t恤', '男女夏季宽松美式复古半袖情侣原创潮牌', 99.00, 19, 1, 'https://gw.alicdn.com/bao/uploaded/i2/57709795/O1CN01miPmZm2MEAPCzoZpN_!!57709795.jpg_.webp', 'active', '2025-04-13 10:05:45', '2025-04-14 01:53:11');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (13, '耐克科比系列男子速干篮球短裤', '夏季新款针织官方NIKE KOBE HJ8104', 279.00, 20, 1, 'https://img.alicdn.com/imgextra/i4/890482188/O1CN01VCcsle1S29dgP81hE-890482188.jpg_.webp', 'active', '2025-04-13 10:07:40', '2025-04-13 10:07:40');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (14, '拉夏贝尔/La Chapelle新中式', '改良旗袍连衣裙套装女夏季小个子汉服', 179.00, 20, 1, 'https://img.alicdn.com/imgextra/i1/2333812388/O1CN01Lkw2PT1TVkjdvWYHd_!!2333812388.jpg_.webp', 'active', '2025-04-13 10:12:02', '2025-04-13 10:12:02');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (15, '时尚polo领', '别致甜辣夏季法式小众短袖t恤女短款显瘦上衣', 78.00, 20, 1, 'https://gw.alicdn.com/imgextra/O1CN01gauVex1mQEk2YuZPM_!!2206588314948-2-C2M.png_580x580q90.jpg', 'active', '2025-04-13 10:16:39', '2025-04-13 10:16:39');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (16, '外套薄款防晒服', 'JEEP吉普户外防晒衣女款夏季新款冰丝防紫外线风衣外套薄款', 87.00, 20, 1, 'https://img.alicdn.com/imgextra/i1/911914351/O1CN01PsZPfu1i0oDl5uZ4i_!!911914351.jpg', 'active', '2025-04-13 10:17:53', '2025-04-13 10:17:53');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (17, 'SIINSIIN【孙怡同款】轻盈鲨鱼裤女', '外穿春秋薄款高腰收腹提臀塑形瑜伽打底\r\n', 99.00, 20, 2, 'https://img10.360buyimg.com/n2/jfs/t1/231736/40/33002/68527/67d24014F9de3766a/e9dd4afa14d9e7a3.jpg', 'active', '2025-04-13 10:23:27', '2025-04-13 10:23:27');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (18, '简约基础款圆领T恤女', '伊芙丽（eifini）【经典延续】伊芙丽索罗纳面料简约基础款圆领T恤女百搭多色短袖 本白色 S 95-105斤', 99.00, 20, 1, 'https://img13.360buyimg.com/n7/jfs/t1/278743/3/11910/59148/67e6cbd3Fbc3f32ad/bd101c6f5abd2b93.jpg', 'active', '2025-04-13 10:24:13', '2025-04-13 10:24:13');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (19, 'SIINSIIN6.0收腹裤强力塑身内裤', '2025新款高腰无痕产后塑形翘臀束腰提臀裤', 69.00, 20, 2, 'https://img10.360buyimg.com/n7/jfs/t1/284816/15/8140/120668/67e24845F805dc363/448b85835d7bb7bd.png', 'active', '2025-04-13 10:24:51', '2025-04-13 10:24:51');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (20, '深呼吸DEEP BREATH女装廓形西装', '直筒西裤套装女A401214 A100401 黑-西装 M (3码)\r\n', 680.00, 20, 1, 'https://img13.360buyimg.com/n7/jfs/t1/231108/17/33901/27326/6760f989Ff7a367f4/76e300f5a0703fd1.jpg', 'active', '2025-04-13 10:25:36', '2025-04-13 10:25:36');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (21, '简约基础款U领T恤女', '2025春装新款百搭多色短袖 本白色 U领 M 105-115斤', 80.00, 20, 1, 'https://img14.360buyimg.com/n7/jfs/t1/280937/19/11117/66469/67e6cbcfF69b3873f/ad594eb59ebc2e41.jpg', 'active', '2025-04-13 10:26:25', '2025-04-13 10:26:25');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (22, '蕉内热皮女士直筒长裤', '工装机能防泼水显腿长运动休闲裤子秋冬女装\r\n', 305.00, 20, 2, 'https://img12.360buyimg.com/n7/jfs/t1/271904/40/17450/22534/67f9043bF2ac42547/51af6777b1ae6948.jpg.avif', 'active', '2025-04-13 10:28:26', '2025-04-13 10:28:26');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (23, '灿图美式速干休闲工装裤女', '个子显瘦高街黑色阔腿运动裤子潮 黑色 L 【建议110斤到120斤】\r\n', 49.00, 20, 2, 'https://img14.360buyimg.com/n7/jfs/t1/244835/20/15506/102163/66975c05F0a197d98/74c294e437fe14c7.jpg.avif', 'active', '2025-04-13 10:29:06', '2025-04-13 10:29:06');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (24, '浪莎冰丝阔腿裤女', '夏季新款显瘦休闲裤薄款高腰垂感宽松九分直筒拖地裤 灰色-常规款 L 建议100斤-115斤', 99.00, 20, 2, 'https://img13.360buyimg.com/n7/jfs/t1/181804/12/27033/155419/630c353dE0aa137bb/b140a5424a71cf56.jpg.avif', 'active', '2025-04-13 10:30:48', '2025-04-13 10:30:48');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (25, 'Teenie Weenie小熊女装短裤', '2025夏季新款时髦英伦休闲学院通勤裤子 卡其色 M', 698.00, 20, 2, 'https://img10.360buyimg.com/n7/jfs/t1/235579/18/38976/55120/67f8d4b3Fa90e6e5c/2d54eb39703a43ac.jpg.avif', 'active', '2025-04-13 10:31:22', '2025-04-13 10:31:22');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (26, '浪莎阔腿裤女', '春秋季小个子高腰垂感休闲裤宽松显瘦运动卫裤加绒香蕉裤 米白-常规 L 建议111-120斤', 99.00, 20, 2, 'https://img14.360buyimg.com/n7/jfs/t1/200136/18/40993/73287/65e85633F57e0def6/266942e579a0155c.jpg.avif', 'active', '2025-04-13 10:32:00', '2025-04-13 10:32:00');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (27, '真维斯（Jeanswest）复古哈伦牛仔裤女', '春秋季新款高腰宽松显瘦小个子九分萝卜老爹裤子 复古蓝九分常规款 M\r\n', 74.00, 20, 2, 'https://img12.360buyimg.com/n7/jfs/t1/101386/24/48765/88101/65fea5cfF4695672c/fc59ba7577b3b5fd.jpg.avif', 'active', '2025-04-13 10:32:38', '2025-04-13 10:32:38');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (28, '玩觅避震鞋', '跑步爽跑鞋新款专业跑步鞋厚底减震运动鞋男情侣鞋子春季款 法拉粉 36', 399.00, 20, 3, 'https://img11.360buyimg.com/n7/jfs/t1/210502/18/49933/503949/6757aa82F72f8742e/fdb1aced3e78a4af.jpg.avif', 'active', '2025-04-13 10:35:21', '2025-04-13 10:35:21');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (29, '筱雪凌帆布男鞋', '2024新款春夏季舒适百搭休闲板鞋学生布鞋平底运动黑色潮 黑色 41 (255mm)', 24.00, 20, 3, 'https://img14.360buyimg.com/n7/jfs/t1/190972/38/37682/191982/64f86c92F486e8558/ad62c6ce610d7522.jpg.avif', 'active', '2025-04-13 10:36:05', '2025-04-13 10:36:05');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (30, '星际华际华棕色作战靴男', '作战鞋超轻高帮侧拉链耐磨训练真皮沙漠登山鞋 棕色新式作战靴 37', 168.00, 20, 3, 'https://img10.360buyimg.com/n7/jfs/t1/263963/2/18425/173518/67ab1a99Fd03f9502/2023b657586870db.jpg.avif', 'active', '2025-04-13 10:36:43', '2025-04-13 10:36:43');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (31, '耐克（NIKE）官方男鞋女鞋 AIR FORCE AF1', '小麦空军一号运动鞋休闲鞋板鞋 CJ9179-200 36', 599.00, 19, 3, 'https://img13.360buyimg.com/n7/jfs/t1/279523/31/19284/127243/67faa68aF4ca0e8db/8d4a31040876e2c5.jpg.avif', 'active', '2025-04-13 10:37:25', '2025-04-13 10:54:14');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (32, '耐克（NIKE）Jordan官方耐克乔丹AJ1板鞋', '男子运动鞋春季金属未来感中帮HV0789 010黑/金属银/白/金属金 41', 799.00, 20, 3, 'https://img20.360buyimg.com/cms/s350x350_jfs/t1/271814/4/19590/131791/67fa70b9Fed450cc2/9ffd116d3596b3a0.jpg', 'active', '2025-04-13 10:38:09', '2025-04-13 10:38:09');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (33, '耐克（NIKE）官方AIR FORCE 1', '男子空军一号运动鞋板鞋春季新款胶底FZ0627 010黑/白/黑 41', 799.00, 19, 3, 'https://img13.360buyimg.com/cms/s350x350_jfs/t1/284741/1/18901/58626/67fa70baFa6b695ee/3cbe4cc559559ec2.jpg', 'active', '2025-04-13 10:38:40', '2025-04-13 10:54:14');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (34, '耐克（NIKE）官方DUNK LOW男子运动鞋', '夏季胶底板鞋低帮复古轻便HF5441 107白/深藏青/白 42', 799.00, 20, 3, 'https://img14.360buyimg.com/cms/s350x350_jfs/t1/270415/39/20209/109262/67fa70baFdfdd5463/a42cece2f5e54518.jpg', 'active', '2025-04-13 10:39:24', '2025-04-13 10:39:24');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (35, '三条杠贝壳头情侣板鞋', '休闲运动板鞋百搭潮流韩版透气男鞋 阿迪达斯(adidas)全黑 43 阿迪达斯(adidas)8', 599.00, 20, 3, 'https://img12.360buyimg.com/n7/jfs/t1/184416/2/47714/50075/66ffe271Fa421d79b/9eb74259f9a60c19.jpg.avif', 'active', '2025-04-13 10:40:34', '2025-04-13 10:40:34');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (36, '阿迪达斯三叶草男女鞋', 'yeezy350V2Boost椰子休闲鞋GW2870UK8.5码42.5码', 899.00, 20, 3, 'https://img13.360buyimg.com/n7/jfs/t1/172799/29/48948/37193/6711dff5F838e61ff/10240347c4a4d734.jpg.avif', 'active', '2025-04-13 10:41:18', '2025-04-13 10:59:47');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (37, 'Adidas阿迪达斯三叶草 男女鞋新款', 'OZWEEGO舒适透气板鞋休闲鞋 FY2023 37', 599.00, 20, 3, 'https://img13.360buyimg.com/n7/jfs/t1/37811/27/15910/268107/60eff1bdE062f51b5/4de3de071d615277.jpg.avif', 'active', '2025-04-13 10:41:50', '2025-04-13 10:41:50');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (38, 'ADIDAS阿迪达斯男鞋子', '2025春夏季板鞋男女士透气防泼水运动鞋滑板休闲鞋 JR5231【官方正品 假一罚十】 42', 599.00, 20, 3, 'https://img12.360buyimg.com/n7/jfs/t1/262382/4/15096/105972/67933746F5f2680f7/6eec9c3c316222ff.jpg.avif', 'active', '2025-04-13 10:42:59', '2025-04-13 10:43:51');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (39, 'Adidas三叶草 阿迪达斯 ', '中性鞋时尚运动舒适休闲鞋 IG4645 42.5', 599.00, 20, 2, 'https://img12.360buyimg.com/n2/jfs/t1/277576/26/19211/72982/67f8a536F0f721a50/94df3de6662f3d0a.jpg', 'active', '2025-04-13 10:44:31', '2025-04-13 10:44:31');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (40, '潘多拉（PANDORA）樱飞舞春项链', '套装玫瑰金色旋转樱花轻奢生日礼物送女友', 1699.00, 9, 4, 'https://img12.360buyimg.com/n7/jfs/t1/271026/33/18933/40747/67f68f2aFf7780cd5/f88de93adec85c35.jpg.avif', 'active', '2025-04-13 10:47:37', '2025-04-13 10:58:02');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (41, '纪思梵（CHEESEFAN）轻奢手链女', '本命年和田玉珠宝首饰情人节纪念日生日礼物女送老婆 星月【蛇】和田玉', 1599.00, 10, 4, 'https://img11.360buyimg.com/n7/jfs/t1/278640/3/188/158587/67ce3babF88afd9bd/ddf28845f70fcd6c.jpg.avif', 'active', '2025-04-13 10:48:07', '2025-04-13 10:48:07');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (42, '纪思梵（CHEESEFAN）轻奢手链女', '四叶草时尚首饰品三八节女神妇女节生日礼物送女友老婆 孔雀石手链', 1399.00, 9, 4, 'https://img11.360buyimg.com/n7/jfs/t1/277316/37/181/159235/67ce3c53Fd7f51d0f/ee9e2e126145be5c.jpg.avif', 'active', '2025-04-13 10:48:46', '2025-04-13 10:58:02');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (43, '栢启歆钛钢锁骨链蛇骨链', '男潮流小众设计感链条项链女百搭高级感配饰饰品 方蛇骨链-55cm', 99.00, 9, 4, 'https://img12.360buyimg.com/n7/jfs/t1/225118/21/19521/85166/665fcf6dFd074c668/9e2f005c6fe52707.jpg.avif', 'active', '2025-04-13 10:49:19', '2025-04-13 10:59:26');
INSERT INTO `product`(`id`, `name`, `description`, `price`, `stock`, `category_id`, `image_url`, `status`, `created_at`, `updated_at`) VALUES (44, '多多洛 男士装饰项链吊坠', '男女毛衣链挂件韩版百搭配饰钛钢复古坠子 蓝色三环（搭配龙骨链+皮链）', 99.00, 10, 4, 'https://img11.360buyimg.com/n7/jfs/t17785/125/1108497884/303569/dbd043f8/5abcf913N1bcd6698.jpg.avif', 'active', '2025-04-13 10:49:49', '2025-04-13 10:49:49');


-- 创建订单表
CREATE TABLE IF NOT EXISTS `order` (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(20) NOT NULL UNIQUE,
    user_id INT NOT NULL,
    status ENUM('pending', 'paid', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
    total_amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50),
    shipping_address TEXT,
    shipping_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `order`(`id`, `order_number`, `user_id`, `status`, `total_amount`, `payment_method`, `shipping_address`, `shipping_phone`, `created_at`, `updated_at`) VALUES (1, '202504140023187156', 2, 'paid', 999.00, 'wechat', NULL, NULL, '2025-04-13 16:23:18', '2025-04-13 16:23:24');
INSERT INTO `order`(`id`, `order_number`, `user_id`, `status`, `total_amount`, `payment_method`, `shipping_address`, `shipping_phone`, `created_at`, `updated_at`) VALUES (2, '202504140939117122', 2, 'paid', 551.00, 'wechat', NULL, NULL, '2025-04-14 01:39:11', '2025-04-14 01:39:18');
INSERT INTO `order`(`id`, `order_number`, `user_id`, `status`, `total_amount`, `payment_method`, `shipping_address`, `shipping_phone`, `created_at`, `updated_at`) VALUES (3, '202504140952257150', 2, 'paid', 999.00, 'wechat', NULL, NULL, '2025-04-14 01:52:26', '2025-04-14 01:52:31');
INSERT INTO `order`(`id`, `order_number`, `user_id`, `status`, `total_amount`, `payment_method`, `shipping_address`, `shipping_phone`, `created_at`, `updated_at`) VALUES (4, '202504140952558184', 2, 'paid', 78.00, 'wechat', NULL, NULL, '2025-04-14 01:52:56', '2025-04-14 01:53:01');
INSERT INTO `order`(`id`, `order_number`, `user_id`, `status`, `total_amount`, `payment_method`, `shipping_address`, `shipping_phone`, `created_at`, `updated_at`) VALUES (5, '202504140953117633', 2, 'paid', 99.00, 'wechat', NULL, NULL, '2025-04-14 01:53:11', '2025-04-14 01:53:17');


-- 创建订单项表
CREATE TABLE IF NOT EXISTS order_item (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES `order`(id),
    FOREIGN KEY (product_id) REFERENCES product(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO `order_item`(`id`, `order_id`, `product_id`, `quantity`, `price`, `created_at`) VALUES (1, 1, 4, 1, 999.00, '2025-04-13 16:23:18');
INSERT INTO `order_item`(`id`, `order_id`, `product_id`, `quantity`, `price`, `created_at`) VALUES (3, 2, 7, 1, 39.00, '2025-04-14 01:39:11');
INSERT INTO `order_item`(`id`, `order_id`, `product_id`, `quantity`, `price`, `created_at`) VALUES (4, 2, 6, 1, 159.00, '2025-04-14 01:39:11');
INSERT INTO `order_item`(`id`, `order_id`, `product_id`, `quantity`, `price`, `created_at`) VALUES (5, 2, 5, 2, 78.00, '2025-04-14 01:39:11');
INSERT INTO `order_item`(`id`, `order_id`, `product_id`, `quantity`, `price`, `created_at`) VALUES (6, 2, 8, 1, 98.00, '2025-04-14 01:39:11');
INSERT INTO `order_item`(`id`, `order_id`, `product_id`, `quantity`, `price`, `created_at`) VALUES (7, 3, 4, 1, 999.00, '2025-04-14 01:52:26');
INSERT INTO `order_item`(`id`, `order_id`, `product_id`, `quantity`, `price`, `created_at`) VALUES (8, 4, 7, 2, 39.00, '2025-04-14 01:52:56');
INSERT INTO `order_item`(`id`, `order_id`, `product_id`, `quantity`, `price`, `created_at`) VALUES (9, 5, 12, 1, 99.00, '2025-04-14 01:53:11');


-- 创建购物车表
CREATE TABLE IF NOT EXISTS cart (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (product_id) REFERENCES product(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建用户行为记录表
CREATE TABLE IF NOT EXISTS user_behavior (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    behavior_type ENUM('view', 'purchase', 'cart') NOT NULL,
    behavior_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (product_id) REFERENCES product(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (1, 2, 4, 'view', '2025-04-13 16:16:18');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (3, 2, 4, 'view', '2025-04-13 16:23:11');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (4, 2, 4, 'cart', '2025-04-13 16:23:12');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (5, 2, 4, 'view', '2025-04-13 16:23:12');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (10, 2, 7, 'view', '2025-04-14 01:38:26');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (11, 2, 7, 'cart', '2025-04-14 01:38:27');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (12, 2, 7, 'view', '2025-04-14 01:38:27');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (13, 2, 7, 'view', '2025-04-14 01:38:30');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (14, 2, 6, 'view', '2025-04-14 01:38:33');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (15, 2, 6, 'cart', '2025-04-14 01:38:34');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (16, 2, 6, 'view', '2025-04-14 01:38:34');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (17, 2, 6, 'view', '2025-04-14 01:38:36');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (18, 2, 5, 'view', '2025-04-14 01:38:38');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (19, 2, 5, 'cart', '2025-04-14 01:38:39');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (20, 2, 5, 'view', '2025-04-14 01:38:39');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (21, 2, 5, 'cart', '2025-04-14 01:38:42');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (22, 2, 5, 'view', '2025-04-14 01:38:42');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (23, 2, 5, 'view', '2025-04-14 01:38:44');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (24, 2, 8, 'view', '2025-04-14 01:38:55');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (25, 2, 8, 'cart', '2025-04-14 01:39:02');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (26, 2, 8, 'view', '2025-04-14 01:39:02');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (27, 2, 13, 'view', '2025-04-14 01:39:23');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (28, 2, 6, 'view', '2025-04-14 01:39:42');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (29, 2, 6, 'view', '2025-04-14 01:43:32');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (30, 2, 4, 'view', '2025-04-14 01:52:19');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (31, 2, 4, 'cart', '2025-04-14 01:52:20');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (32, 2, 4, 'view', '2025-04-14 01:52:20');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (33, 2, 4, 'purchase', '2025-04-14 01:52:31');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (34, 2, 7, 'view', '2025-04-14 01:52:50');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (35, 2, 7, 'cart', '2025-04-14 01:52:51');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (36, 2, 7, 'view', '2025-04-14 01:52:51');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (37, 2, 7, 'cart', '2025-04-14 01:52:52');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (38, 2, 7, 'view', '2025-04-14 01:52:52');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (39, 2, 7, 'purchase', '2025-04-14 01:53:01');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (40, 2, 12, 'view', '2025-04-14 01:53:07');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (41, 2, 12, 'cart', '2025-04-14 01:53:08');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (42, 2, 12, 'view', '2025-04-14 01:53:08');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (43, 2, 12, 'purchase', '2025-04-14 01:53:17');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (44, 2, 8, 'view', '2025-04-14 01:53:23');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (45, 2, 4, 'view', '2025-04-14 02:00:45');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (46, 2, 4, 'view', '2025-04-14 02:01:14');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (47, 2, 4, 'view', '2025-04-14 02:04:18');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (48, 2, 4, 'view', '2025-04-14 02:16:50');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (49, 2, 4, 'view', '2025-04-14 02:16:55');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (50, 1, 4, 'view', '2025-04-14 02:17:56');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (51, 1, 4, 'view', '2025-04-14 02:18:07');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (52, 1, 4, 'view', '2025-04-14 02:18:09');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (53, 1, 4, 'view', '2025-04-14 02:18:12');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (54, 1, 6, 'view', '2025-04-14 02:18:17');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (55, 1, 7, 'view', '2025-04-14 02:23:50');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (56, 1, 6, 'view', '2025-04-14 02:23:55');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (57, 1, 10, 'view', '2025-04-14 02:24:04');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (58, 1, 15, 'view', '2025-04-14 02:24:08');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (59, 2, 5, 'view', '2025-04-14 02:24:29');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (60, 2, 10, 'view', '2025-04-14 02:24:40');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (61, 2, 5, 'view', '2025-04-14 02:27:10');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (62, 1, 7, 'view', '2025-04-14 02:27:46');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (63, 1, 7, 'view', '2025-04-14 02:33:53');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (64, 2, 7, 'view', '2025-04-14 02:34:05');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (65, 2, 7, 'view', '2025-04-14 02:35:24');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (66, 2, 7, 'view', '2025-04-14 02:35:27');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (67, 2, 6, 'view', '2025-04-14 02:35:33');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (68, 2, 6, 'view', '2025-04-14 02:38:10');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (69, 1, 7, 'view', '2025-04-14 02:38:33');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (70, 1, 18, 'view', '2025-04-14 02:38:42');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (71, 1, 27, 'view', '2025-04-14 02:38:49');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (72, 1, 11, 'view', '2025-04-14 02:39:09');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (73, 1, 14, 'view', '2025-04-14 02:39:12');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (74, 1, 17, 'view', '2025-04-14 02:39:16');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (75, 1, 23, 'view', '2025-04-14 02:39:20');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (76, 1, 28, 'view', '2025-04-14 02:39:25');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (77, 1, 7, 'view', '2025-04-14 02:43:33');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (78, 2, 7, 'view', '2025-04-14 02:43:50');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (79, 2, 7, 'view', '2025-04-14 02:47:56');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (80, 2, 7, 'view', '2025-04-14 02:48:00');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (81, 1, 7, 'view', '2025-04-14 02:48:46');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (82, 1, 7, 'view', '2025-04-14 02:49:05');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (83, 1, 7, 'view', '2025-04-14 02:49:27');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (84, 2, 7, 'view', '2025-04-14 02:50:40');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (85, 2, 7, 'view', '2025-04-14 02:52:20');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (86, 2, 7, 'view', '2025-04-14 02:52:26');
INSERT INTO `user_behavior`(`id`, `user_id`, `product_id`, `behavior_type`, `behavior_time`) VALUES (87, 2, 5, 'view', '2025-04-14 02:52:30');

-- 创建商品相似度表
CREATE TABLE IF NOT EXISTS product_similarity (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    similar_product_id INT NOT NULL,
    similarity_score DECIMAL(5,4) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES product(id),
    FOREIGN KEY (similar_product_id) REFERENCES product(id),
    UNIQUE KEY unique_similarity (product_id, similar_product_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (241, 4, 5, 0.9734, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (242, 5, 4, 0.9734, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (243, 4, 6, 0.9999, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (244, 6, 4, 0.9999, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (245, 4, 7, 0.9999, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (246, 7, 4, 0.9999, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (247, 4, 8, 0.9734, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (248, 8, 4, 0.9734, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (249, 4, 10, 0.8503, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (250, 10, 4, 0.8503, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (251, 4, 12, 0.9734, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (252, 12, 4, 0.9734, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (253, 4, 13, 0.9734, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (254, 13, 4, 0.9734, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (255, 4, 15, 0.2290, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (256, 15, 4, 0.2290, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (257, 4, 18, 0.2290, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (258, 18, 4, 0.2290, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (259, 4, 27, 0.2290, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (260, 27, 4, 0.2290, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (261, 5, 6, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (262, 6, 5, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (263, 5, 7, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (264, 7, 5, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (265, 5, 8, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (266, 8, 5, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (267, 5, 10, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (268, 10, 5, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (269, 5, 12, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (270, 12, 5, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (271, 5, 13, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (272, 13, 5, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (273, 6, 7, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (274, 7, 6, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (275, 6, 8, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (276, 8, 6, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (277, 6, 10, 0.8437, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (278, 10, 6, 0.8437, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (279, 6, 12, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (280, 12, 6, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (281, 6, 13, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (282, 13, 6, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (283, 6, 15, 0.2169, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (284, 15, 6, 0.2169, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (285, 6, 18, 0.2169, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (286, 18, 6, 0.2169, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (287, 6, 27, 0.2169, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (288, 27, 6, 0.2169, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (289, 7, 8, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (290, 8, 7, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (291, 7, 10, 0.8437, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (292, 10, 7, 0.8437, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (293, 7, 12, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (294, 12, 7, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (295, 7, 13, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (296, 13, 7, 0.9762, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (297, 7, 15, 0.2169, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (298, 15, 7, 0.2169, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (299, 7, 18, 0.2169, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (300, 18, 7, 0.2169, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (301, 7, 27, 0.2169, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (302, 27, 7, 0.2169, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (303, 8, 10, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (304, 10, 8, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (305, 8, 12, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (306, 12, 8, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (307, 8, 13, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (308, 13, 8, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (309, 10, 12, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (310, 12, 10, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (311, 10, 13, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (312, 13, 10, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (313, 10, 15, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (314, 15, 10, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (315, 10, 18, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (316, 18, 10, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (317, 10, 27, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (318, 27, 10, 0.7071, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (319, 12, 13, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (320, 13, 12, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (321, 15, 18, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (322, 18, 15, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (323, 15, 27, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (324, 27, 15, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (325, 18, 27, 1.0000, '2025-04-14 02:39:00');
INSERT INTO `product_similarity`(`id`, `product_id`, `similar_product_id`, `similarity_score`, `created_at`) VALUES (326, 27, 18, 1.0000, '2025-04-14 02:39:00');

-- 创建系统设置表
CREATE TABLE IF NOT EXISTS system_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(50) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_description TEXT,
    setting_type ENUM('text', 'number', 'boolean', 'json') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入默认系统设置
INSERT INTO system_settings (setting_key, setting_value, setting_description, setting_type) VALUES
('site_name', '服装购物系统', '网站名称', 'text'),
('site_description', '专业的服装购物平台', '网站描述', 'text'),
('maintenance_mode', 'false', '维护模式', 'boolean'),
('maintenance_end_time', '', '维护模式预计结束时间', 'text'),
('order_prefix', 'ORD', '订单号前缀', 'text'),
('max_upload_size', '5242880', '最大上传文件大小(字节)', 'number'),
('allowed_image_types', '["jpg","jpeg","png","gif"]', '允许上传的图片类型', 'json'),
('contact_email', 'support@example.com', '联系邮箱', 'text'),
('contact_phone', '400-123-4567', '联系电话', 'text'),
('shipping_fee', '10', '基础运费', 'number'),
('free_shipping_threshold', '99', '免运费阈值', 'number');

-- 创建评论表
CREATE TABLE IF NOT EXISTS comment (
    id INT AUTO_INCREMENT PRIMARY KEY,
    content TEXT NOT NULL,
    rating INT NOT NULL,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES user(id),
    FOREIGN KEY (product_id) REFERENCES product(id),
    CHECK (rating BETWEEN 1 AND 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (22, '春秋季小个子高腰垂感休闲裤宽松显瘦运动卫裤加绒香蕉裤 米白-常规 L 建议111-120斤', 4, 2, 25, '2025-04-13 10:32:00');
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (23, '复古哈伦牛仔裤女', 4, 2, 26, '2025-04-13 10:32:38');
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (24, '跑步爽跑鞋新款专业跑步鞋厚底减震运动鞋男情侣鞋子春季款 法拉粉 36', 4, 2, 27, '2025-04-13 10:35:21');
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (25, '2024新款春夏季舒适百搭休闲板鞋学生布鞋平底运动黑色潮 黑色 41 (255mm)', 4, 2, 28, '2025-04-13 10:36:05');
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (26, '作战鞋超轻高帮侧拉链耐磨训练真皮沙漠登山鞋 棕色新式作战靴 37', 4, 2, 29, '2025-04-13 10:36:43');
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (27, '小麦空军一号运动鞋休闲鞋板鞋 CJ9179-200 36', 4, 2, 30, '2025-04-13 10:37:25');
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (28, '男子运动鞋春季金属未来感中帮HV0789 010黑/金属银/白/金属金 41', 4, 2, 31, '2025-04-13 10:38:09');
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (29, '男子空军一号运动鞋板鞋春季新款胶底FZ0627 010黑/白/黑 41', 4, 2, 32, '2025-04-13 10:38:40');
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (30, '夏季胶底板鞋低帮复古轻便HF5441 107白/深藏青/白 42', 4, 2, 33, '2025-04-13 10:39:24');
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (31, '休闲运动板鞋百搭潮流韩版透气男鞋 阿迪达斯(adidas)全黑 43 阿迪达斯(adidas)8', 4, 2, 34, '2025-04-13 10:40:34');
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (32, 'yeezy350V2Boost椰子休闲鞋GW2870UK8.5码42.5码', 4, 2, 35, '2025-04-13 10:41:18');
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (33, 'OZWEEGO舒适透气板鞋休闲鞋 FY2023 37', 4, 2, 36, '2025-04-13 10:41:50');
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (34, '2025春夏季板鞋男女士透气防泼水运动鞋滑板休闲鞋 JR5231【官方正品 假一罚十】 42', 4, 2, 37, '2025-04-13 10:42:59');
INSERT INTO `comment`(`id`, `content`, `rating`, `user_id`, `product_id`, `created_at`) VALUES (35, '中性鞋时尚运动舒适休闲鞋 IG4645 42.5', 4, 2, 38, '2025-04-13 10:44:31');




-- 创建销售统计视图
CREATE OR REPLACE VIEW sales_statistics AS
SELECT 
    DATE(created_at) as sale_date,
    COUNT(DISTINCT id) as order_count,
    SUM(total_amount) as total_sales
FROM `order`
WHERE status != 'cancelled'
GROUP BY DATE(created_at);

-- 创建商品分类销售视图
CREATE OR REPLACE VIEW category_sales AS
SELECT 
    c.name as category_name,
    COUNT(o.id) as order_count,
    SUM(oi.quantity * oi.price) as total_amount
FROM category c
LEFT JOIN product p ON c.id = p.category_id
LEFT JOIN order_item oi ON p.id = oi.product_id
LEFT JOIN `order` o ON oi.order_id = o.id AND o.status != 'cancelled'
GROUP BY c.id, c.name;

-- 创建管理员仪表盘视图
CREATE OR REPLACE VIEW admin_dashboard AS
SELECT
    (SELECT COUNT(*) FROM user WHERE is_admin = FALSE) as total_users,
    (SELECT COUNT(*) FROM `order` WHERE status != 'cancelled') as total_orders,
    (SELECT COUNT(*) FROM product WHERE status = 'active') as total_products,
    (SELECT COALESCE(SUM(total_amount), 0) FROM `order` 
     WHERE DATE(created_at) = CURDATE() AND status != 'cancelled') as today_sales;


-- 创建存储过程：获取日期范围内的销售趋势
DELIMITER //
CREATE PROCEDURE get_sales_trend(IN start_date DATE, IN end_date DATE)
BEGIN
    SELECT 
        DATE(created_at) as date,
        COUNT(*) as order_count,
        SUM(total_amount) as sales_amount
    FROM `order`
    WHERE DATE(created_at) BETWEEN start_date AND end_date
    AND status != 'cancelled'
    GROUP BY DATE(created_at)
    ORDER BY date;
END //
DELIMITER ; 