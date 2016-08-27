// This project was started based on 'C' code found in the book:
// Practical RAY TRACING in C by Craig A. Lindley
// 
namespace Finray {

#ifndef __BYTE
#define __BYTE
typedef unsigned __int8 BYTE;
#endif

#define BIG		1e10
#define EPSILON	1e-03
#define MAXRECURSELEVEL	7

#define MIN(a,b)	(((a) > (b)) ? (b) : (a))
#define MAX(a,b)	(((a) > (b)) ? (a) : (b))
#define SQUARE(x)	((x) * (x))

class AnObject;
class ALight;

class Ray
{
	double minT;
	AnObject *minObjectPtr;
public:
	Vector origin;
	Vector dir;
	void Trace(Color *clr);
	void Test(AnObject *);
};

class Viewpoint
{
public:
	Vector loc;
	Vector dir;
	Vector up;
	Vector right;
	Viewpoint() {
		loc.x = 0.0;
		loc.y = 0.0;
		loc.z = 0.0;
		dir.x = 0.0;
		dir.y = 0.0;
		dir.z = 0.0;
		up.x = 0.0;
		up.y = 0.0;
		up.z = 0.0;
		right.x = 0.0;
		right.y = 0.0;
		right.z = 0.0;
	};
};

class Surface
{
public:
	Color color;	// base color
	Color variance;
	Color acolor;	// color with ambience pre-calculated
	Color ambient;
	float diffuse;
	float brilliance;
	float specular;	// phong
	float roughness;
	float reflection;
	bool transparent;
	Surface();
	Surface(Surface *);
	void SetAttrib(float rd, float gr, float bl, Color a, float d, float b, float s, float ro, float r);
	void SetColorVariance(Color v) { variance = v; };
};

enum {
	OBJ_OBJECT = 1,
	OBJ_SPHERE,
	OBJ_PLANE,
	OBJ_TRIANGLE,
	OBJ_RECTANGLE,
	OBJ_CONE,
	OBJ_CYLINDER,
	OBJ_QUADRIC,
	OBJ_CUBE,
	OBJ_BOX,
	OBJ_LIGHT
};

class AnObject {
public:
	unsigned int type;
	bool doReflections;
	bool doShadows;
	bool doImage;
	AnObject *next;
	AnObject *obj;
	AnObject *posobj;
	AnObject *negobj;
	AnObject *boundingObject;
	ALight *lights;
	Surface properties;
	AnObject();
	int Print(AnObject *);
	void SetAttrib(float rd, float gr, float bl, Color a, float d, float b, float s, float ro, float r);
	Color Shade(Ray *ray, Vector normal, Vector point, Color *color);
	virtual void SetColorVariance(Color v) { properties.SetColorVariance(v); };
	int Intersect(Ray *, double *);
	bool AntiIntersects(Ray *);
	virtual void SetTexture(Surface *tx) { properties = *tx; };
	virtual void SetColor(Color c) { properties.color = c; };
	virtual Color GetColor(Vector point);
	virtual Vector Normal(Vector) { return Vector(); };
	virtual void Translate(double x, double y, double z);
	virtual void Translate(Vector v) { Translate(Vector(v.x,v.y,v.z)); };
	virtual void Scale(Vector v) {};
	virtual void RotXYZ(double, double, double);
	virtual void RotX(double a) {};
	virtual void RotY(double a) {};
	virtual void RotZ(double a) {};
	virtual void Print() {} ;
};


class AQuadric : public AnObject
{
public:
	double A,B,C,D,E,F,G,H,I,J;
	AQuadric();
	AQuadric(double a, double b, double c, double d, double e,
			double f, double g, double h, double i, double j);
	int Intersect(Ray *, double *);
	Vector Normal(Vector);
	void Print();
	void SetTexture(Surface *tx) { properties = *tx; };
	void SetColor(Color c) { properties.color = c; };
	Color GetColor(Vector point) { return properties.color; };
	void Translate(double x, double y, double z);
	void RotXYZ(double, double, double);
	void RotX(double a) { RotXYZ(a, 0.0, 0.0); };
	void RotY(double a) { RotXYZ(0.0, a, 0.0); };
	void RotZ(double a) { RotXYZ(0.0, 0.0, a); };
	void ToMatrix(Matrix *) const;
	void FromMatrix(Matrix *);
	void TransformX(Transform *tr);
};


class ASphere : public AnObject
{
public:
	Vector center;
	double radius;
	double radius2;	// radius squared
	ASphere();
	ASphere(Vector P, double R);
	ASphere(double x,double y ,double z,double rad);
	void SetTexture(Surface *tx) { properties = *tx; };
	void SetColor(Color c) { properties.color = c; };
	Color GetColor(Vector point) { return properties.color; };
	int Intersect(Ray *, double *);
	Vector Normal(Vector);
	void Translate(double x, double y, double z) {
		center.x = x; center.y = y; center.z = z;
	};
	void Scale(Vector s);
	void Print();
	void RotX(double);
	void RotY(double);
	void RotZ(double);
};

/*
class ACylinder : public AnObject
{
public:
	Vector axis;
	Vector center;
	double radius;
	double radius2;	// radius squared
	double height;
	ACylinder();
	double Intersect(Ray *);
	Vector Normal(Vector);
	void Print();
};
*/

class APlane : public AnObject
{
public:
	Vector normal;
	double distance;
	APlane();
	APlane(double,double,double,double);
	void SetTexture(Surface *tx) { properties = *tx; };
	void SetColor(Color c) { properties.color = c; };
	Color GetColor(Vector point) { return properties.color; };
	int Intersect(Ray *, double *);
	Vector Normal(Vector);
	void Print() {};
	void Translate(double x, double y, double z) {};
	void RotX(double);
	void RotY(double);
	void RotZ(double);
};

class ATriangle : public AnObject
{
	void CalcCentroid();
public:
	Vector normal, unnormal;
	Vector u, v;
	double uu, vv, uv;	// vars for intersection testing
	double D;			// denominator
	Vector p1, p2, p3;
	Vector pc;			// centroid for translations
	ATriangle();
	ATriangle(Vector a, Vector b, Vector c);
	void SetTexture(Surface *tx) { properties = *tx; };
	void SetColor(Color c) { properties.color = c; };
	Color GetColor(Vector point) { return properties.color; };
	void Init();
	void CalcNormal();
	bool InternalSide(Vector pt1, Vector pt2, Vector a, Vector b);
	bool PointInTriangle(Vector p);
	int Intersect(Ray *, double *);
	Vector Normal(Vector);
	void Print() {};
	void Translate(Vector p);
	void Translate(double x, double y, double z);
	void Scale(Vector s);
	void RotX(double);
	void RotY(double);
	void RotZ(double);
};


class ACone : public AnObject
{
public:
	enum {
		BODY,
		BASE,
		APEX
	};
	Vector base, apex;
	Vector baseNormal, apexNormal, bodyNormal;
	double baseRadius, apexRadius;
	double length;
	static const double tolerance;
	Transform trans;
	unsigned int intersectedPart : 2;
	unsigned int openBase : 1;
	unsigned int openApex : 1;
	ACone(Vector b, Vector a, double rb, double ra);
	void SetTexture(Surface *tx) { properties = *tx; };
	void SetColor(Color c) { properties.color = c; };
	Color GetColor(Vector point) { return properties.color; };
	void TransformX(Transform *t);
	void CalcCylinderTransform();
	void CalcTransform();
	Vector Normal(Vector);
	int Intersect(Ray *, double *);
	void Translate(double x, double y, double z);
	void Scale(double x, double y, double z);
	void Scale(Vector v);
	void Print() {};
	void RotXYZ(double,double,double);
};

class ACylinder : public ACone
{
public:
	ACylinder(Vector b, Vector a, double r);
	void CalcTransform();
	int Intersect(Ray *, double *);
};

class ABox : public AnObject
{
public:
	double maxLength;
	ATriangle *tri[12];
	ABox();
	ABox(Vector pt, Vector dist);
	ABox(double x, double y, double z);
	void CalcBoundingObject();
	Vector CalcCenter();
	Vector Normal(Vector v);
	void SetTexture(Surface *tx);
	void SetColor(Color c);
	void SetVariance(Color v);
	Color GetColor(Vector point) { return properties.color; };
	int Intersect(Ray *, double *);
	void Print() {};
	void Translate(Vector p);
	void Translate(double x, double y, double z);
	void Scale(Vector s);
	void RotX(double);
	void RotY(double);
	void RotZ(double);
};

class ARectangle : public AnObject
{
public:
	Vector normal;
	Vector p1, p2, p3, p4;
	ARectangle(Vector a, Vector b, Vector c, Vector d);
	void SetTexture(Surface *tx) { properties = *tx; };
	void SetColor(Color c) { properties.color = c; };
	int Intersect(Ray *, double *);
	void CalcNormal();
	Vector Normal(Vector);
	void Translate(double x, double y, double z) {};
	void Print() {};
	void RotX(double);
	void RotY(double);
	void RotZ(double);
};

class ALight : public AnObject
{
public:
	Vector center;
	double Intersect(Ray *) { return 0.0; };
	Vector Normal(Vector) { return Vector(); };
	ALight(double, double, double, float, float, float);
	void SetTexture(Surface *tx) { properties = *tx; };
	void SetColor(Color c) { properties.color = c; };
	Color GetColor() { return properties.color; };
	void Print() {};
	Finray::Color GetColor(AnObject *objPtr, Ray *ray, double distance);
	double MakeRay(Vector point, Ray *ray);
	void RotX(double);
	void RotY(double);
	void RotZ(double);
};

ref class FinrayException : public System::Exception
{
public:
	int data;
	int errnum;
	FinrayException(int e, int d) { data = d; errnum = e; };
};

enum {
	TK_EOF = 0,
	TK_AMBIENT = 256,
	TK_ANTI,
	TK_APPROXIMATE,
	TK_BACKGROUND,
	TK_BOX,
	TK_BRILLIANCE,
	TK_CAMERA,
	TK_COLOR,
	TK_CONE,
	TK_COS,
	TK_CUBE,
	TK_CYLINDER,
	TK_DIFFUSE,
	TK_DIRECTION,
	TK_FOR,
	TK_ICONST,
	TK_INCLUDE,
	TK_ID,
	TK_LIGHT,
	TK_LIGHT_SOURCE,
	TK_LOCATION,
	TK_LOOK_AT,
	TK_NO_REFLECTION,
	TK_NO_SHADOW,
	TK_NUM,
	TK_OBJECT,
	TK_OPEN,
	TK_PHONG,
	TK_PHONGSIZE,
	TK_PLANE,
	TK_QUADRIC,
	TK_RAND,
	TK_RANDV,
	TK_RCONST,
	TK_RECTANGLE,
	TK_REFLECTION,
	TK_REPEAT,
	TK_RIGHT,
	TK_ROTATE,
	TK_ROUGHNESS,
	TK_SIN,
	TK_SPECULAR,
	TK_SPHERE,
	TK_TEXTURE,
	TK_TO,
	TK_TRANSLATE,
	TK_TRIANGLE,
	TK_UP,
	TK_VIEW_POINT
};

enum {
	ERR_SYNTAX = 1,
	ERR_EXPECT_TOKEN,
	ERR_FPCON,
	ERR_TEXTURE,
	ERR_TOOMANY_SYMBOLS,
	ERR_UNDEFINED,
	ERR_MISMATCH_TYP,
	ERR_FILEDEPTH,
	ERR_NOVIEWPOINT,
	ERR_TOOMANY_OBJECTS,
	ERR_NONPLANER,
	ERR_ASSIGNMENT,
	ERR_ILLEGALOP,
	ERR_BADTYPE,
	ERR_SINGULAR_MATRIX,
	ERR_DEGENERATE,
};

enum {
	TYP_NONE = 0,
	TYP_INT,
	TYP_NUM,
	TYP_VECTOR,
	TYP_COLOR,
	TYP_TEXT,
	TYP_SPHERE,
	TYP_PLANE,
	TYP_TRIANGLE,
	TYP_RECTANGLE,
	TYP_QUADRIC,
	TYP_CONE,
	TYP_CYLINDER,
	TYP_CUBE,
	TYP_BOX,
	TYP_OBJECT,
	TYP_TEXTURE,
	TYP_VIEWPOINT,
	TYP_LIGHT
};

class Value
{
public:
	int type;
	int i;
	double d;
	Color c;
	Vector v;
	union {
		ACone *cn;
		ACylinder *cy;
		ASphere *sp;
		APlane *pl;
		Viewpoint *vp;
		Surface *tx;
		AQuadric *qd;
		AnObject *obj;
		ALight *lt;
	} val;
};

class Symbol
{
public:
	std::string varname;
	Value value;
};

class SymbolTable
{
	Symbol symbols[1000];
public:
	int count;
	SymbolTable();
	Symbol *Find(std::string nm);
	void Add(Symbol *sym);
};

class Parser
{
	int mfp;
	int token;
	double rval;
	double last_num;
	Color last_color;
	Vector last_vector;
	int level;				// Parse level
	int lastch;
	char fbuf[2000000];
	char lastid[64];
	char lastkw[64];
	Symbol *symbol;
	__int64 ival;
	__int64 radix36(char c);
	void getbase(__int64 b);
	void getfrac();
	void getexp();
	void getnum();
	void SkipSpaces();
	void ScanToEOL();
	int isalnum(char c);
	int isidch(char c);
	int isspace(char c);
	int isdigit(char c);
	Value Unary();
	Value Multdiv();
	Value Addsub();
	Value eval();
	void getid();
	bool Test(int);
	Color ParseAmbient();
	ACone *ParseCone();
	ACylinder *ParseCylinder();
	Color ParseApproximate(AnObject *obj);
	void ParseNoReflection2(AnObject *obj);
	void ParseNoReflection(AnObject *obj);
	void ParseNoShadow2(AnObject *obj);
	void ParseNoShadow(AnObject *obj);
	Color ParseColor();
	Surface *ParseTexture(Surface *texture);
	void ParseObjectBody(AnObject *obj);
	ALight *ParseLight();
	ASphere *ParseSphere();
	ABox *ParseBox();
	ABox *ParseCube();
	APlane *ParsePlane();
	ATriangle *ParseTriangle();
	ARectangle *ParseRectangle();
	AQuadric *ParseQuadric();
	AnObject *ParseObject();
	Viewpoint *ParseViewPoint();
	AnObject *ParseFor(AnObject *);
	void Need(int);
	void Was(int);
	int NextToken();
public:
	char *p;
	Parser();
	Value ParseBuffer(char *buf);
	void Parse(std::string path);
};

class RayTracer
{
public:
	int recurseLevel;
	AnObject *objectList;
	ALight *lightList;
	Viewpoint *viewPoint;
	Parser parser;
	SymbolTable symbolTable;
	RayTracer() {
		Init();
	}
	void Init();
	void Add(AnObject *);
	void Add(ALight *);
	void DeleteList(AnObject *);
	void DeleteList();
};

};