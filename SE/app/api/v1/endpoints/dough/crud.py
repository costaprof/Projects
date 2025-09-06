import logging
import uuid

from sqlalchemy.orm import Session

from app.api.v1.endpoints.dough.schemas import DoughCreateSchema
from app.database.models import Dough


def create_dough(schema: DoughCreateSchema, db: Session):
    entity = Dough(**schema.dict())
    db.add(entity)
    db.commit()
    logging.info(f'Dough created with name {entity.name} and stock {entity.stock}')
    return entity


def get_dough_by_id(dough_id: uuid.UUID, db: Session):
    entity = db.query(Dough).filter(Dough.id == dough_id).first()
    logging.info(f'Dough retrieved with id {dough_id}')
    return entity


def get_dough_by_name(dough_name: str, db: Session):
    entity = db.query(Dough).filter(Dough.name == dough_name).first()
    logging.info(f'Dough retrieved with name {dough_name}')
    return entity


def get_all_doughs(db: Session):
    logging.info('Getting all doughs')
    return db.query(Dough).all()


def update_dough(dough: Dough, changed_dough: DoughCreateSchema, db: Session):
    for key, value in changed_dough.dict().items():
        setattr(dough, key, value)

    db.commit()
    db.refresh(dough)
    entity = Dough(**changed_dough.dict())
    logging.info(f'Dough updated with name {entity.name} stock {entity.stock}')
    return dough


def delete_dough_by_id(dough_id: uuid.UUID, db: Session):
    entity = get_dough_by_id(dough_id, db)
    if entity:
        logging.info(f'Dough deleted with id {dough_id}')
        db.delete(entity)
        db.commit()
