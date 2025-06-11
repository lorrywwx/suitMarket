# 导入必要的模块
from flask import Blueprint, request, redirect, url_for, flash, render_template
from flask_login import current_user, login_required
from models.models import db, Order, OrderItem, Cart, Product
from models.recommendation import RecommendationSystem
import random
import string
from datetime import datetime

# 创建订单相关的蓝图
order_bp = Blueprint('order', __name__)

# 创建订单
@order_bp.route('/order/create', methods=['POST'])
@login_required
def create_order():
    # 检查用户状态
    if current_user.status != 'active':
        flash('账户已被禁用，无法创建订单', 'error')
        return redirect(url_for('cart.cart'))
        
    # 获取购物车商品
    cart_items = Cart.query.filter_by(user_id=current_user.id).all()
    
    if not cart_items:
        flash('购物车为空', 'error')
        return redirect(url_for('cart.cart'))
    
    # 生成订单号：10位随机字符
    order_number = ''.join(random.choices(string.ascii_uppercase + string.digits, k=10))
    
    # 计算订单总金额
    total_amount = sum(item.product.price * item.quantity for item in cart_items)
    
    # 创建订单对象
    order = Order(
        order_number=order_number,
        user_id=current_user.id,
        total_amount=total_amount,
        status='pending',  # 订单状态：待支付
        shipping_address=current_user.address,
        shipping_phone=current_user.phone
    )
    
    try:
        # 添加订单到数据库
        db.session.add(order)
        db.session.flush()  # 获取订单ID
        
        # 创建订单项
        for cart_item in cart_items:
            # 创建订单项对象
            order_item = OrderItem(
                order_id=order.id,
                product_id=cart_item.product_id,
                quantity=cart_item.quantity,
                price=cart_item.product.price
            )
            db.session.add(order_item)
            
            # 更新商品库存
            product = cart_item.product
            product.stock -= cart_item.quantity
        
        # 清空购物车
        Cart.query.filter_by(user_id=current_user.id).delete()
        
        # 提交所有更改
        db.session.commit()
        flash('订单创建成功', 'success')
        # 重定向到支付页面
        return redirect(url_for('main.pay_order', order_id=order.id))
        
    except Exception as e:
        # 发生错误时回滚数据库更改
        db.session.rollback()
        flash('订单创建失败，请重试', 'error')
        return redirect(url_for('cart.cart')) 