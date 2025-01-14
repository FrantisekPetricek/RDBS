from sqlalchemy import create_engine, MetaData, Table, text, Column, Integer, String, ForeignKey
from sqlalchemy.orm import declarative_base, sessionmaker, aliased

Base = declarative_base()

class Management(Base):
    __tablename__ = "management"

    id = Column(Integer, primary_key=True, autoincrement=True)
    jmeno = Column(String(50), nullable=False, unique=True)
    id_nadrizeneho = Column(Integer, ForeignKey("management.id"), nullable=True)
    
engine = create_engine('mysql+pymysql://root:a@localhost:3306/pc_sestavy')

Management.__table__.drop(engine)

Base.metadata.create_all(engine) 

Session = sessionmaker(bind=engine)
session = Session()


session.execute(text("Select * from management"))
session.commit()



management_values = [
    Management(jmeno="Adam", id_nadrizeneho = None),
    Management(jmeno="Honza", id_nadrizeneho = 1),
    Management(jmeno="Monika", id_nadrizeneho = 1),
    Management(jmeno="Jirka", id_nadrizeneho = 1),
    Management(jmeno="Karel", id_nadrizeneho = 2),
    Management(jmeno="Ondra", id_nadrizeneho = 4)
]
try:
    session.add_all(management_values)
    session.commit()
    session.close()
except Exception as e:
    print(e)


with engine.connect() as connection:
    result = connection.execute(text("Select * from management")) 
    #result = connection.execute(text("SELECT * FROM management"))
    #result = connection.execute(text("SELECT PrumerCenaPcGPU(1)"))
    for row in result:
        print(row)
    

nadrizeny_alias = aliased(Management)

odsazeny = 20
result = (
    session.query(Management.jmeno.label("zamestnanec"), nadrizeny_alias.jmeno.label("nadrizeny"))
    .join(nadrizeny_alias, Management.id_nadrizeneho == nadrizeny_alias.id).all()
)
print("--" * 20)
print("Zaměstnanec".ljust(odsazeny), "Nadřízený", end="\n\n")
for zamestnanec, nadrizeny in result:
    print(f"{zamestnanec}".ljust(odsazeny), f"{nadrizeny}")