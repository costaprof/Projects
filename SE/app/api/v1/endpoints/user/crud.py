import logging
import uuid

from sqlalchemy.orm import Session

from app.api.v1.endpoints.user.schemas import UserCreateSchema
from app.database.models import Order
from app.database.models import User


def create_user(schema: UserCreateSchema, db: Session):
    entity = User(**schema.dict())
    db.add(entity)
    db.commit()
    logging.info(f'User {entity.id} created')
    return entity


def get_user_by_username(username: str, db: Session):
    entity = db.query(User).filter(User.username == username).first()
    logging.info(f'User {username} found')
    return entity


def get_user_by_id(user_id: uuid.UUID, db: Session):
    entity = db.query(User).filter(User.id == user_id).first()
    logging.info(f'User {user_id} found')
    return entity


def get_all_users(db: Session):
    entities = db.query(User).all()
    logging.info('Retrieved all Users')
    return entities


def update_user(user: User, changed_user: UserCreateSchema, db: Session):
    for key, value in changed_user.dict().items():
        setattr(user, key, value)

    db.commit()
    db.refresh(user)
    entity = User(**changed_user.dict())
    logging.info(f'User {entity.id} updated')
    return user


def delete_user_by_id(user_id: uuid.UUID, db: Session):
    entity = get_user_by_id(user_id, db)
    if entity:
        logging.info(f'User {user_id} deleted')
        db.delete(entity)
        db.commit()


def get_order_history_of_user(user_id: uuid.UUID, db: Session):
    entities = db.query(Order) \
        .filter(Order.user_id == user_id) \
        .filter(Order.order_status == 'COMPLETED').all()
    logging.info(f'Retrieved History of User {user_id}')
    return entities


def get_open_orders_of_user(user_id: uuid.UUID, db: Session):
    entities = db.query(Order) \
        .filter(Order.user_id == user_id) \
        .filter(Order.order_status != 'COMPLETED').all()
    logging.info(f'Retrieved open orders of User {user_id}')
    return entities


def get_all_not_completed_orders(db: Session):
    entities = db.query(Order) \
        .filter(Order.order_status != 'COMPLETED').all()
    logging.info('Retrieved all not completed orders')
    return entities
