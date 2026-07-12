const { prisma } = require('../database/db');

async function findByEmail(email) {
  return prisma.user.findUnique({
    where: { email },
    include: {
      roles: {
        include: {
          role: true
        }
      }
    }
  });
}

async function findById(id) {
  return prisma.user.findUnique({
    where: { id },
    include: {
      roles: {
        include: {
          role: true
        }
      }
    }
  });
}

async function create(data, roleId) {
  return prisma.$transaction(async (tx) => {
    const user = await tx.user.create({
      data: {
        email: data.email,
        passwordHash: data.passwordHash,
        firstName: data.firstName,
        lastName: data.lastName,
        isActive: data.isActive !== undefined ? data.isActive : true
      }
    });

    await tx.userRole.create({
      data: {
        userId: user.id,
        roleId
      }
    });

    return tx.user.findUnique({
      where: { id: user.id },
      include: {
        roles: {
          include: {
            role: true
          }
        }
      }
    });
  });
}

module.exports = {
  findByEmail,
  findById,
  create
};
