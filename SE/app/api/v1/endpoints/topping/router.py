import uuid
import logging
from typing import List

from fastapi import APIRouter, Depends, Request, Response, status, HTTPException
from fastapi.responses import RedirectResponse
from sqlalchemy.orm import Session

import app.api.v1.endpoints.topping.crud as topping_crud
from app.api.v1.endpoints.topping.schemas import ToppingSchema, ToppingCreateSchema, ToppingListItemSchema
from app.database.connection import SessionLocal

router = APIRouter()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.get('', response_model=List[ToppingListItemSchema], tags=['topping'])
def get_all_toppings(db: Session = Depends(get_db)):
    logging.info('Fetching all toppings.')
    toppings = topping_crud.get_all_toppings(db)
    logging.info(f'{len(toppings)} toppings retrieved.')
    return toppings


@router.post('', response_model=ToppingSchema, status_code=status.HTTP_201_CREATED, tags=['topping'])
def create_topping(topping: ToppingCreateSchema, request: Request, db: Session = Depends(get_db)):
    logging.info(f'Attempting to create a new topping: {topping.dict()}')
    topping_found = topping_crud.get_topping_by_name(topping.name, db)

    if topping_found:
        logging.warning(f'Topping with name {topping.name} already exists.')
        url = request.url_for('get_topping', topping_id=topping_found.id)
        return RedirectResponse(url=url, status_code=status.HTTP_303_SEE_OTHER)

    new_topping = topping_crud.create_topping(topping, db)
    logging.info(f'Topping {topping.name} created successfully with ID {new_topping.id}.')
    return new_topping


@router.put('/{topping_id}', response_model=ToppingSchema, tags=['topping'])
def update_topping(
        topping_id: uuid.UUID,
        changed_topping: ToppingCreateSchema,
        request: Request,
        response: Response,
        db: Session = Depends(get_db),
):
    logging.info(f'Attempting to update topping with ID {topping_id}.')
    topping_found = topping_crud.get_topping_by_id(topping_id, db)

    if not topping_found:
        logging.error(f'Topping with ID {topping_id} not found.')
        raise HTTPException(status_code=404)

    if topping_found.name == changed_topping.name:
        topping_crud.update_topping(topping_found, changed_topping, db)
        logging.info(f'Topping with ID {topping_id} updated successfully.')
        return Response(status_code=status.HTTP_204_NO_CONTENT)

    topping_name_found = topping_crud.get_topping_by_name(changed_topping.name, db)
    if topping_name_found:
        logging.warning(f'Topping with name {changed_topping.name} already exists.')
        url = request.url_for('get_topping', topping_id=topping_name_found.id)
        return RedirectResponse(url=url, status_code=status.HTTP_303_SEE_OTHER)

    updated_topping = topping_crud.create_topping(changed_topping, db)
    logging.info(f'Topping with ID {topping_id} updated to new name {changed_topping.name}')
    response.status_code = status.HTTP_201_CREATED
    return updated_topping


@router.get('/{topping_id}', response_model=ToppingSchema, tags=['topping'])
def get_topping(topping_id: uuid.UUID, response: Response, db: Session = Depends(get_db)):
    logging.info(f'Fetching topping with ID {topping_id}.')
    topping = topping_crud.get_topping_by_id(topping_id, db)

    if not topping:
        logging.error(f'Topping with ID {topping_id} not found.')
        raise HTTPException(status_code=404)

    logging.info(f'Topping retrieved: {topping.name} (ID: {topping.id})')
    return topping


@router.delete('/{topping_id}', response_model=None, tags=['topping'])
def delete_topping(topping_id: uuid.UUID, db: Session = Depends(get_db)):
    logging.info(f'Attempting to delete topping with ID {topping_id}.')
    topping = topping_crud.get_topping_by_id(topping_id, db)

    if not topping:
        logging.error(f'Topping with ID {topping_id} not found.')
        raise HTTPException(status_code=404)

    topping_crud.delete_topping_by_id(topping_id, db)
    logging.info(f'Topping with ID {topping_id} deleted successfully.')
    return Response(status_code=status.HTTP_204_NO_CONTENT)
